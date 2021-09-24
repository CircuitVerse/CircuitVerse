describe ActivityNotification::PolymorphicHelpers, type: :helper do

  include ActivityNotification::PolymorphicHelpers

  describe 'extended String class' do
    describe "as public instance methods" do
      describe '#to_model_name' do
        it 'returns singularized and camelized string' do
          expect('foo_bars'.to_model_name).to eq('FooBar')
          expect('users'.to_model_name).to eq('User')
        end
      end

      describe '#to_model_class' do
        it 'returns class instance' do
          expect('users'.to_model_class).to eq(User)
        end
      end

      describe '#to_resource_name' do
        it 'returns singularized underscore string' do
          expect('FooBars'.to_resource_name).to eq('foo_bar')
        end
      end

      describe '#to_resources_name' do
        it 'returns pluralized underscore string' do
          expect('FooBar'.to_resources_name).to eq('foo_bars')
        end
      end

      describe '#to_boolean' do
        context 'without default argument' do
          it 'returns true for string true' do
            expect('true'.to_boolean).to eq(true)
          end
  
          it 'returns true for string 1' do
            expect('1'.to_boolean).to eq(true)
          end
  
          it 'returns true for string yes' do
            expect('yes'.to_boolean).to eq(true)
          end
  
          it 'returns true for string on' do
            expect('on'.to_boolean).to eq(true)
          end
  
          it 'returns true for string t' do
            expect('t'.to_boolean).to eq(true)
          end
  
          it 'returns false for string false' do
            expect('false'.to_boolean).to eq(false)
          end
  
          it 'returns false for string 0' do
            expect('0'.to_boolean).to eq(false)
          end
  
          it 'returns false for string no' do
            expect('no'.to_boolean).to eq(false)
          end
  
          it 'returns false for string off' do
            expect('off'.to_boolean).to eq(false)
          end
  
          it 'returns false for string f' do
            expect('f'.to_boolean).to eq(false)
          end

          it 'returns nil for other string' do
            expect('hoge'.to_boolean).to be_nil
          end
        end

        context 'with default argument' do
          it 'returns default value for other string' do
            expect('hoge'.to_boolean(true)).to eq(true)
            expect('hoge'.to_boolean(false)).to eq(false)
          end
        end
      end
    end
  end

end
