require 'json'
require 'swagger/blocks'

# TODO: Test data originally based on the Swagger UI example data

RESOURCE_LISTING_JSON_V3 = open(File.expand_path('../swagger_v3_api_declaration.json', __FILE__)).read

class PetControllerV3
  include Swagger::Blocks

  swagger_root do
    key :openapi, '3.0.0'
    info version: '1.0.1' do
      key :title, 'Swagger Petstore'
      key :description, 'A sample API that uses a petstore as an example to ' \
                        'demonstrate features in the swagger-2.0 specification'
      key :termsOfService, 'http://helloreverb.com/terms/'
      contact do
        key :name, 'Wordnik API Team'
      end
      license do
        key :name, 'MIT'
      end
    end

    server do
      key :url, 'http://petstore.swagger.io/v1'
      key :description, 'Petstore API'
    end

    server do
      key :url, 'https://{subdomain}.site.com/{version}'
      key :description, 'The main prod server'

      variable :subdomain do
        key :default, :production
      end
      variable :version do
        key :enum, ['v1', 'v2']
        key :default, :v2
      end
    end

    security do
      key :ApiKeyAuth, []
    end
    security do
      key :OAuth2, ['read', 'write']
    end

    extension :'x-tagGroups' do
      key :name, 'Pets'
      key :tags, ['dogs', 'cats']
    end

    tag do
      key :name, 'dogs'
      key :description, 'Dogs'
    end

    tag do
      key :name, 'cats'
      key :description, 'Cats'
    end
  end

  swagger_path '/pets' do
    key :description, 'Perform actions on pet resources'
    server do
      key :url, 'http://petstore.swagger.io/'
      key :description, 'Petstore API (without version prefix)'
    end
    operation :get do
      key :summary, 'List all pets'
      key :operationId, 'listPets'
      key :tags, [
        'pets'
      ]
      parameter do
        key :name, :limit
        key :in, :query
        key :description, 'How many items to return at one time (max 100)'
        key :required, false
        schema do
          key :type, :integer
          key :format, :int32
        end
        example :large do
          key :value, 100
          key :summary, 'Return a maximum of 100 results'
        end
        example :small do
          key :value, 5
          key :summary, 'Return a maximum of 5 results'
        end
      end
      server do
        key :url, 'http://petstore.swagger.io/2.1/'
        key :description, 'Petstore API (with version 2.1 prefix)'
      end
      response 200 do
        key :description, 'A paged array of pets'
        header :'x-next' do
          key :description, 'A link to the next page of responses'
          schema do
            key :type, :string
          end
        end
        content :'application/json' do
          schema do
            key :'$ref', :Pets
          end
          example :Rabbit do
            value do
              key :id, 10
              key :name, 'Rabbit'
            end
          end
          example :Cat do
            key :'$ref', :Cat
          end
        end
        link :getPetById do
          key :'$ref', '#/components/links/GetPetById'
        end
      end
      response :default do
        key :description, 'unexpected error'
        content :'application/json' do
          schema do
            key :'$ref', :Error
          end
        end
      end
    end
    operation :post do
      key :summary, 'Create a pet'
      key :operationId, 'createPets'
      key :tags, [
        'pets'
      ]
      request_body do
        key :description, 'Pet to add to the store'
        key :required, true
        content 'application/json' do
          schema do
            property :name do
              key :type, :string
            end
            example do
              key :name, 'Fluffy'
            end
          end
        end
      end
      response 201 do
        key :description, 'New Pet'
        content :'application/json' do
          schema do
            key :'$ref', :Pet
          end
        end
        link :getPetById do
          key :operationId, 'showPetById'
          parameters do
            key :id, '$response.body#/id'
          end
          key :description, 'The `id` value returned in the response can be used as the `petId` parameter in `GET /pets/{petId}`.'
        end
      end
      response :default, description: 'unexpected error' do
        content :'application/json' do
          schema do
            key :'$ref', :Error
          end
        end
      end
    end
  end

  swagger_path '/pets/{petId}' do
    parameter do
      key :name, :petId
      key :in, :path
      key :required, true
      key :description, 'The id of the pet to retrieve'
      schema do
        key :type, 'string'
      end
    end
    operation :get do
      key :summary, 'Info for a specific pet'
      key :operationId, 'showPetById'
      key :tags, [
        'pets'
      ]
      response 200 do
        key :description, 'Expected response to a valid request'
        content :'application/json' do
          schema do
            key :'$ref', :Pet
          end
        end
      end
      response :default do
        key :description, 'unexpected error'
        content :'application/json' do
          schema do
            key :'$ref', :Error
          end
        end
      end
    end
    operation :post do
      key :summary, 'Update info for a specific pet'
      key :operationId, 'updatePetById'
      key :tags, [
        'pets'
      ]
      request_body do
        key :"$ref", :PetBody
      end
      response 200 do
        key :'$ref', :UpdatePetBodyResponse
      end
      response :default do
        key :description, 'unexpected error'
        content :'application/json' do
          schema do
            key :'$ref', :Error
          end
        end
      end
    end
    operation :put do
      key :summary, 'Replace info for a specific pet'
      key :operationId, 'replacePetById'
      key :tags, [
        'pets'
      ]
      request_body do
        key :"$ref", :PetBody
      end
      response 200 do
        key :'$ref', :ReplacePetBodyResponse
      end
      response :default do
        key :description, 'unexpected error'
        content :'application/json' do
          schema do
            key :'$ref', :Error
          end
        end
      end
    end
  end
end

class PetV3
  include Swagger::Blocks

  swagger_path '/pets/{petId}/purchase' do
    operation :post do
      key :summary, 'Purchase a specific pet'
      key :operationId, 'purchasePetById'
      key :deprecated, true
      key :tags, [
        'pets'
      ]
      parameter do
        key :$ref, :petId
      end
      request_body do
        key :description, 'Pet order object'
        key :required, true
        content 'application/json' do
          schema do
            one_of do
              key :'$ref', 'PetOrderRequest'
            end
            one_of do
              key :'$ref', 'ComplexPetOrderRequest'
            end
          end
          example do
            key :id, 10
            key :name, 'Fluffy'
          end
        end
      end
      response 201 do
        key :description, 'Expected response to a valid request'
        content :'application/json' do
          schema do
            key :'$ref', :PetOrder
          end
        end
      end
      response :default do
        key :description, 'unexpected error'
        content :'application/json' do
          schema do
            key :'$ref', :Error
          end
        end
      end

      callback :orderUpdated do
        destination '{$request.body#/webhook_url}' do
          method :post do
            request_body do
              key :required, true
              content 'application/json' do
                schema do
                  key :'$ref', :OrderUpdated
                end
              end
            end
            response 200 do
              key :description, 'The server must return an HTTP 200, otherwise delivery will be reattempted.'
            end
          end
        end
      end
    end
  end
  swagger_component do
    schema :Pet, required: [:id, :name] do
      property :id do
        key :type, :integer
        key :format, :int64
      end
      property :name do
        key :type, :string
      end
      property :tag_ids do
        key :type, :array
        items do
          key :type, :integer
          key :format, :int64
          key :example, 1
        end
        key :example, [1, 2, 3]
      end
    end

    schema :Pets do
      key :type, :array
      items do
        key :'$ref', :Pet
      end
      key :example, [{ id: 10, name: 'Rover' }, { id: 20, name: 'Felicity' }]
    end

    schema :PetOrderRequest, required: [:phone_number] do
      property :phone_number do
        key :type, :string
      end
      property :webhook_url do
        key :type, :string
      end
    end

    schema :PetOrder, required: [:phone_number, :id, :status] do
      property :id do
        key :type, :integer
        key :format, :int64
      end
      property :phone_number do
        key :type, :string
      end
      property :webhook_url do
        key :type, :string
      end
      property :status do
        key :type, :string
      end
    end

    schema :OrderUpdated, required: [:order_id, :status, :phone_number] do
      property :order_id do
        key :type, :integer
        key :format, :int64
      end
      property :phone_number do
        key :type, :string
      end
      property :status do
        key :type, :string
      end
      example do
        key :order_id, 123
        key :phone_number, '3125556666'
        key :status, 'complete'
      end
    end

    link :GetPetById do
      key :operationId, :showPetById
      parameters do
        key :petId, '$response.body#/id'
      end
    end

    example :PetExample do
      value do
        key :id, 1
        key :name, 'Rover'
      end
      key :summary, 'An example pet response'
    end
    security_scheme :BasicAuth do
      key :type, :http
      key :scheme, :basic
    end
    security_scheme :BearerAuth do
      key :type, :http
      key :scheme, :bearer
    end
    security_scheme :ApiKeyAuth do
      key :type, :apiKey
      key :in, :header
      key :name, :"X-API-Key"
    end
    security_scheme :OpenID do
      key :type, :openIdConnect
      key :openIdConnectUrl, 'https://example.com/.well-known/openid-configuration'
    end
    parameter :petId do
      key :name, :petId
      key :in, :path
      key :required, true
      key :description, 'The id of the pet to retrieve'
      schema do
        key :type, 'string'
      end
    end
    request_body :PetBody do
      key :description, 'A JSON object containing pet information'
      key :required, true
      content :'application/json' do
        schema do
          key :'$ref', :Pet
        end
      end
    end
    response :ReplacePetBodyResponse do
      key :description, 'Expected response to a valid request'
      content :'application/json' do
        schema do
          key :'$ref', :Pet
        end
      end
    end
  end
end

class ErrorModelV3
  include Swagger::Blocks

  swagger_component do
    schema :Error do
      key :required, [:code, :message]
      property :code do
        key :type, :integer
        key :format, :int32
      end
      property :message do
        key :type, :string
      end
    end
  end
end

class AuxiliaryModelV3
  include Swagger::Blocks

  swagger_component do
    response :UpdatePetBodyResponse do
      key :description, 'Expected response to a valid request'
      content :'application/json' do
        schema do
          key :'$ref', :Pet
        end
      end
    end
    example :Cat do
      value do
        key :id, 1
        key :name, 'Felicity'
      end
      key :summary, 'An example cat response'
    end
    security_scheme :OAuth2 do
      key :type, :oauth2
      flow :authorizationCode do
        key :authorizationUrl, 'https://example.com/oauth/authorize'
        key :tokenUrl, 'https://example.com/oauth/token'
        scopes do
          key :read, 'Grants read access'
          key :write, 'Grants write access'
          key :admin, 'Grants access to admin operations'
        end
      end
    end
  end
end

describe 'Swagger::Blocks v3' do
  describe 'build_json' do
    it 'outputs the correct data' do
      swaggered_classes = [
        PetControllerV3,
        PetV3,
        ErrorModelV3,
        AuxiliaryModelV3
      ]
      actual = Swagger::Blocks.build_root_json(swaggered_classes)
      actual = JSON.parse(actual.to_json) # For access consistency.
      data = JSON.parse(RESOURCE_LISTING_JSON_V3)

      # Multiple expectations for better test diff output.
      expect(actual['info']).to eq(data['info'])
      expect(actual['x-tagGroups']).to eq(data['x-tagGroups'])
      expect(actual['paths']).to be
      expect(actual['paths']['/pets']).to be
      expect(actual['paths']['/pets']).to eq(data['paths']['/pets'])
      expect(actual['paths']['/pets/{petId}']).to be
      expect(actual['paths']['/pets/{petId}']['get']).to be
      expect(actual['paths']['/pets/{petId}']['get']).to eq(data['paths']['/pets/{petId}']['get'])
      expect(actual['paths']).to eq(data['paths'])
      expect(actual['components']).to eq(data['components'])
      expect(actual).to eq(data)
    end

    it 'is idempotent' do
      swaggered_classes = [PetControllerV3, PetV3, ErrorModelV3, AuxiliaryModelV3]
      actual = JSON.parse(Swagger::Blocks.build_root_json(swaggered_classes).to_json)
      data = JSON.parse(RESOURCE_LISTING_JSON_V3)
      expect(actual).to eq(data)
    end

    it 'errors if no swagger_root is declared' do
      expect do
        Swagger::Blocks.build_root_json([])
      end.to raise_error(Swagger::Blocks::DeclarationError)
    end

    it 'errors if multiple swagger_roots are declared' do
      expect do
        Swagger::Blocks.build_root_json([PetControllerV3, PetControllerV3])
      end.to raise_error(Swagger::Blocks::DeclarationError)
    end
  end
end
