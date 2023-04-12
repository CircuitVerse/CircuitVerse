# frozen_string_literal: true

require 'spec_helper'

describe Coveralls::Configuration do
  before do
    allow(ENV).to receive(:[]).and_return(nil)
  end

  describe '.configuration' do
    it 'returns a hash with the default keys' do
      config = described_class.configuration
      expect(config).to be_a(Hash)
      expect(config.keys).to include(:environment)
      expect(config.keys).to include(:git)
    end

    context 'with yaml_config' do
      let(:repo_token) { SecureRandom.hex(4) }
      let(:repo_secret_token) { SecureRandom.hex(4) }
      let(:yaml_config) do
        {
          'repo_token'        => repo_token,
          'repo_secret_token' => repo_secret_token
        }
      end

      before do
        allow(File).to receive(:exist?).with(described_class.configuration_path).and_return(true)
        allow(YAML).to receive(:load_file).with(described_class.configuration_path).and_return(yaml_config)
      end

      it 'sets the Yaml config and associated variables if present' do
        config = described_class.configuration
        expect(config[:configuration]).to eq(yaml_config)
        expect(config[:repo_token]).to eq(repo_token)
      end

      it 'uses the repo_secret_token if the repo_token is not set' do
        yaml_config.delete('repo_token')
        config = described_class.configuration
        expect(config[:configuration]).to eq(yaml_config)
        expect(config[:repo_token]).to eq(repo_secret_token)
      end
    end

    context 'when repo_token is in environment' do
      let(:repo_token) { SecureRandom.hex(4) }

      before do
        allow(ENV).to receive(:[]).with('COVERALLS_REPO_TOKEN').and_return(repo_token)
      end

      it 'pulls the repo token from the environment if set' do
        config = described_class.configuration
        expect(config[:repo_token]).to eq(repo_token)
      end
    end

    context 'when parallel is in environment' do
      before do
        allow(ENV).to receive(:[]).with('COVERALLS_PARALLEL').and_return(true)
      end

      it 'sets parallel to true if present' do
        config = described_class.configuration
        expect(config[:parallel]).to be true
      end
    end

    context 'when flag_name is in environment' do
      before do
        allow(ENV).to receive(:[]).with('COVERALLS_FLAG_NAME').and_return(true)
      end

      it 'sets flag_name to true if present' do
        config = described_class.configuration
        expect(config[:flag_name]).to be true
      end
    end

    context 'with services' do
      def services
        {
          appveyor:        'APPVEYOR',
          circleci:        'CIRCLECI',
          gitlab:          'GITLAB_CI',
          jenkins:         'JENKINS_URL',
          semaphore:       'SEMAPHORE',
          tddium:          'TDDIUM',
          travis:          'TRAVIS',
          coveralls_local: 'COVERALLS_RUN_LOCALLY',
          generic:         'CI_NAME'
        }
      end

      shared_examples 'a service' do |service_name|
        let(:service_variable) { options[:service_variable] }

        before do
          allow(ENV).to receive(:[]).with(services[service_name]).and_return('1')
          described_class.configuration
        end

        it 'sets service parameters for this service and no other' do
          services.each_key.reject { |service| service == service_name }.each do |service|
            expect(described_class).not_to have_received(:"define_service_params_for_#{service}")
          end

          expect(described_class).to have_received(:"define_service_params_for_#{service_name}") unless service_name == :generic
          expect(described_class).to have_received(:define_standard_service_params_for_generic_ci)
        end
      end

      before do
        services.each_key do |service|
          allow(described_class).to receive(:"define_service_params_for_#{service}")
        end

        allow(described_class).to receive(:define_standard_service_params_for_generic_ci)
      end

      context 'with env based service name' do
        let(:service_name) { 'travis-enterprise' }

        before do
          allow(ENV).to receive(:[]).with('TRAVIS').and_return('1')
          allow(ENV).to receive(:[]).with('COVERALLS_SERVICE_NAME').and_return(service_name)
        end

        it 'pulls the service name from the environment if set' do
          config = described_class.configuration
          expect(config[:service_name]).to eq(service_name)
        end
      end

      context 'when using AppVeyor' do
        it_behaves_like 'a service', :appveyor
      end

      context 'when using CircleCI' do
        it_behaves_like 'a service', :circleci
      end

      context 'when using GitLab CI' do
        it_behaves_like 'a service', :gitlab
      end

      context 'when using Jenkins' do
        it_behaves_like 'a service', :jenkins
      end

      context 'when using Semaphore' do
        it_behaves_like 'a service', :semaphore
      end

      context 'when using Tddium' do
        it_behaves_like 'a service', :tddium
      end

      context 'when using Travis' do
        it_behaves_like 'a service', :travis
      end

      context 'when running Coveralls locally' do
        it_behaves_like 'a service', :coveralls_local
      end

      context 'when using a generic CI' do
        it_behaves_like 'a service', :generic
      end
    end
  end

  describe '.define_service_params_for_travis' do
    let(:travis_job_id) { SecureRandom.hex(4) }

    before do
      allow(ENV).to receive(:[]).with('TRAVIS_JOB_ID').and_return(travis_job_id)
    end

    it 'sets the service_job_id' do
      config = {}
      described_class.define_service_params_for_travis(config, nil)
      expect(config[:service_job_id]).to eq(travis_job_id)
    end

    it 'sets the service_name to travis-ci by default' do
      config = {}
      described_class.define_service_params_for_travis(config, nil)
      expect(config[:service_name]).to eq('travis-ci')
    end

    it 'sets the service_name to a value if one is passed in' do
      config = {}
      random_name = SecureRandom.hex(4)
      described_class.define_service_params_for_travis(config, random_name)
      expect(config[:service_name]).to eq(random_name)
    end
  end

  describe '.define_service_params_for_circleci' do
    let(:circle_workflow_id) { 1234 }
    let(:ci_pull_request) { 'repo/pull/12' }
    let(:circle_build_num) { SecureRandom.hex(4) }
    let(:circle_sha1) { SecureRandom.hex(32) }
    let(:circle_branch) { SecureRandom.hex(4) }

    before do
      allow(ENV).to receive(:[]).with('CIRCLE_WORKFLOW_ID').and_return(circle_workflow_id)
      allow(ENV).to receive(:[]).with('CI_PULL_REQUEST').and_return(ci_pull_request)
      allow(ENV).to receive(:[]).with('CIRCLE_BUILD_NUM').and_return(circle_build_num)
      allow(ENV).to receive(:[]).with('CIRCLE_SHA1').and_return(circle_sha1)
      allow(ENV).to receive(:[]).with('CIRCLE_BRANCH').and_return(circle_branch)
    end

    it 'sets the expected parameters' do
      config = {}
      described_class.define_service_params_for_circleci(config)
      expect(config).to include(
        service_name:         'circleci',
        service_number:       circle_workflow_id,
        service_pull_request: '12',
        service_job_number:   circle_build_num,
        git_commit:           circle_sha1,
        git_branch:           circle_branch
      )
    end
  end

  describe '.define_service_params_for_gitlab' do
    let(:commit_sha) { SecureRandom.hex(32) }
    let(:service_job_number) { 'spec:one' }
    let(:service_job_id) { 1234 }
    let(:service_branch) { 'feature' }
    let(:service_number) { 5678 }

    before do
      allow(ENV).to receive(:[]).with('CI_BUILD_NAME').and_return(service_job_number)
      allow(ENV).to receive(:[]).with('CI_PIPELINE_ID').and_return(service_number)
      allow(ENV).to receive(:[]).with('CI_BUILD_ID').and_return(service_job_id)
      allow(ENV).to receive(:[]).with('CI_BUILD_REF_NAME').and_return(service_branch)
      allow(ENV).to receive(:[]).with('CI_BUILD_REF').and_return(commit_sha)
    end

    it 'sets the expected parameters' do
      config = {}
      described_class.define_service_params_for_gitlab(config)
      expect(config).to include(
        service_name:       'gitlab-ci',
        service_number:     service_number,
        service_job_number: service_job_number,
        service_job_id:     service_job_id,
        service_branch:     service_branch,
        commit_sha:         commit_sha
      )
    end
  end

  describe '.define_service_params_for_semaphore' do
    let(:semaphore_workflow_id) { 1234 }
    let(:semaphore_git_pr_number) { 10 }
    let(:semaphore_git_working_branch) { 'pr-branch' }
    let(:semaphore_job_id) { 5678 }
    let(:semaphore_organization_url) { 'an-organization' }

    before do
      allow(ENV).to receive(:[]).with('SEMAPHORE_WORKFLOW_ID').and_return(semaphore_workflow_id)
      allow(ENV).to receive(:[]).with('SEMAPHORE_GIT_PR_NUMBER').and_return(semaphore_git_pr_number)
      allow(ENV).to receive(:[]).with('SEMAPHORE_GIT_WORKING_BRANCH').and_return(semaphore_git_working_branch)
      allow(ENV).to receive(:[]).with('SEMAPHORE_JOB_ID').and_return(semaphore_job_id)
      allow(ENV).to receive(:[]).with('SEMAPHORE_ORGANIZATION_URL').and_return(semaphore_organization_url)
    end

    it 'sets the expected parameters' do
      config = {}
      described_class.define_service_params_for_semaphore(config)
      expect(config).to include(
        service_name:         'semaphore',
        service_number:       semaphore_workflow_id,
        service_job_id:       semaphore_job_id,
        service_build_url:    "#{semaphore_organization_url}/jobs/#{semaphore_job_id}",
        service_branch:       semaphore_git_working_branch,
        service_pull_request: semaphore_git_pr_number
      )
    end
  end

  describe '.define_service_params_for_jenkins' do
    let(:service_pull_request) { '1234' }
    let(:build_num) { SecureRandom.hex(4) }

    before do
      allow(ENV).to receive(:[]).with('CI_PULL_REQUEST').and_return(service_pull_request)
      allow(ENV).to receive(:[]).with('BUILD_NUMBER').and_return(build_num)
    end

    it 'sets the expected parameters' do
      config = {}
      described_class.define_service_params_for_jenkins config
      described_class.define_standard_service_params_for_generic_ci config
      expect(config).to include(
        service_name:         'jenkins',
        service_number:       build_num,
        service_pull_request: service_pull_request
      )
    end
  end

  describe '.define_service_params_for_coveralls_local' do
    it 'sets the expected parameters' do
      config = {}
      described_class.define_service_params_for_coveralls_local(config)
      expect(config).to include(
        service_name:       'coveralls-ruby',
        service_job_id:     nil,
        service_event_type: 'manual'
      )
    end
  end

  describe '.define_service_params_for_generic_ci' do
    let(:service_name) { SecureRandom.hex(4) }
    let(:service_number) { SecureRandom.hex(4) }
    let(:service_build_url) { SecureRandom.hex(4) }
    let(:service_branch) { SecureRandom.hex(4) }
    let(:service_pull_request) { '1234' }

    before do
      allow(ENV).to receive(:[]).with('CI_NAME').and_return(service_name)
      allow(ENV).to receive(:[]).with('CI_BUILD_NUMBER').and_return(service_number)
      allow(ENV).to receive(:[]).with('CI_BUILD_URL').and_return(service_build_url)
      allow(ENV).to receive(:[]).with('CI_BRANCH').and_return(service_branch)
      allow(ENV).to receive(:[]).with('CI_PULL_REQUEST').and_return(service_pull_request)
    end

    it 'sets the expected parameters' do
      config = {}
      described_class.define_standard_service_params_for_generic_ci(config)
      expect(config).to include(
        service_name:         service_name,
        service_number:       service_number,
        service_build_url:    service_build_url,
        service_branch:       service_branch,
        service_pull_request: service_pull_request
      )
    end
  end

  describe '.define_service_params_for_appveyor' do
    let(:service_number) { SecureRandom.hex(4) }
    let(:service_branch) { SecureRandom.hex(4) }
    let(:commit_sha) { SecureRandom.hex(4) }
    let(:repo_name) { SecureRandom.hex(4) }

    before do
      allow(ENV).to receive(:[]).with('APPVEYOR_BUILD_VERSION').and_return(service_number)
      allow(ENV).to receive(:[]).with('APPVEYOR_REPO_BRANCH').and_return(service_branch)
      allow(ENV).to receive(:[]).with('APPVEYOR_REPO_COMMIT').and_return(commit_sha)
      allow(ENV).to receive(:[]).with('APPVEYOR_REPO_NAME').and_return(repo_name)
    end

    it 'sets the expected parameters' do
      config = {}
      described_class.define_service_params_for_appveyor(config)
      expect(config).to include(
        service_name:      'appveyor',
        service_number:    service_number,
        service_branch:    service_branch,
        commit_sha:        commit_sha,
        service_build_url: format('https://ci.appveyor.com/project/%<repo_name>s/build/%<service_number>s', repo_name: repo_name, service_number: service_number)
      )
    end
  end

  describe '.define_service_params_for_tddium' do
    let(:service_number)       { SecureRandom.hex(4) }
    let(:service_job_number)   { SecureRandom.hex(4) }
    let(:service_pull_request) { SecureRandom.hex(4) }
    let(:service_branch)       { SecureRandom.hex(4) }

    before do
      allow(ENV).to receive(:[]).with('TDDIUM_SESSION_ID').and_return(service_number)
      allow(ENV).to receive(:[]).with('TDDIUM_TID').and_return(service_job_number)
      allow(ENV).to receive(:[]).with('TDDIUM_PR_ID').and_return(service_pull_request)
      allow(ENV).to receive(:[]).with('TDDIUM_CURRENT_BRANCH').and_return(service_branch)
    end

    it 'sets the expected parameters' do
      config = {}
      described_class.define_service_params_for_tddium(config)
      expect(config).to include(
        service_name:         'tddium',
        service_number:       service_number,
        service_job_number:   service_job_number,
        service_pull_request: service_pull_request,
        service_branch:       service_branch,
        service_build_url:    format('https://ci.solanolabs.com/reports/%<service_number>s', service_number: service_number)
      )
    end
  end

  describe '.git' do
    let(:git_id) { SecureRandom.hex(2) }
    let(:author_name) { SecureRandom.hex(4) }
    let(:author_email) { SecureRandom.hex(4) }
    let(:committer_name) { SecureRandom.hex(4) }
    let(:committer_email) { SecureRandom.hex(4) }
    let(:message) { SecureRandom.hex(4) }
    let(:branch) { SecureRandom.hex(4) }

    before do
      allow(ENV).to receive(:fetch).with('GIT_ID', anything).and_return(git_id)
      allow(ENV).to receive(:fetch).with('GIT_AUTHOR_NAME', anything).and_return(author_name)
      allow(ENV).to receive(:fetch).with('GIT_AUTHOR_EMAIL', anything).and_return(author_email)
      allow(ENV).to receive(:fetch).with('GIT_COMMITTER_NAME', anything).and_return(committer_name)
      allow(ENV).to receive(:fetch).with('GIT_COMMITTER_EMAIL', anything).and_return(committer_email)
      allow(ENV).to receive(:fetch).with('GIT_MESSAGE', anything).and_return(message)
      allow(ENV).to receive(:fetch).with('GIT_BRANCH', anything).and_return(branch)
    end

    it 'uses ENV vars' do
      config = described_class.git
      expect(config[:branch]).to eq(branch)
      expect(config[:head]).to include(
        id:              git_id,
        author_name:     author_name,
        author_email:    author_email,
        committer_name:  committer_name,
        committer_email: committer_email,
        message:         message
      )
    end
  end
end
