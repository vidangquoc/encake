require 'spec_helper'

describe Array do      
    
  describe 'to_hashes:' do
    
    describe 'passing it a serie of symbols as keys' do
      
      it 'converts an array of arrays to array of hashes' do        
        array_of_arrays = [ [1,2], [3,4] ]        
        expect(array_of_arrays.to_hashes(:a, :b)).to eq [ {:a => 1, :b => 2}, {:a => 3, :b => 4} ]
      end
      
    end
    
    describe 'passing it a hash as the mapping of hearders and keys:' do
      
      it 'converts an array of arrays to array of hashes' do
        array_of_arrays = [ ['first','second'], [1,2], [3,4] ]
        expect(array_of_arrays.to_hashes({'first' => :a, 'second' => :b, 'third' => :c})).to eq [ {:a => 1, :b => 2}, {:a => 3, :b => 4} ]        
      end
      
      it 'ignores extra spaces in headers' do                    
        array_of_arrays       = [ [' first  item ','  second   item'], [1,2], [3,4] ]
        headers_keys_mapping  = {'  first      item  ' => :a, 'second      item ' => :b}          
        expect(array_of_arrays.to_hashes(headers_keys_mapping)).to eq [ {:a => 1, :b => 2}, {:a => 3, :b => 4} ]          
      end
      
      it 'is case-insensitive in headers mapping' do          
        array_of_arrays       = [ ['FIRST ITEM','SECOND ITEM'], [1,2], [3,4] ]
        headers_keys_mapping  = {'First Item' => :a, 'Second ITEM' => :b}
        expect(array_of_arrays.to_hashes(headers_keys_mapping)).to eq [ {:a => 1, :b => 2}, {:a => 3, :b => 4} ]                    
      end
      
      it 'raises HeaderMappingException if it cannot find mapping for a header' do
        array_of_arrays       = [ ['not found'], [1] ]
        headers_keys_mapping  = {'item' => :a}
        expect { array_of_arrays.to_hashes(headers_keys_mapping) }.to raise_exception(HeaderMappingException)
      end
        
    end
    
                     
  end
  
  describe 'extract_hashes' do
    
    before :each do
      @array_of_hashes = [ {:a => 1, :b => 2, :c => 3}, {:a => 4, :b => 5, :c => 6} ]
    end
    
    it 'returns an array of sub-hashes from an array of hashes' do                
      expect(@array_of_hashes.extract_hashes(:a, :b)).to eq [ {:a => 1, :b => 2}, {:a => 4, :b => 5} ]        
    end
    
    it 'passes each sub-hash to a given block' do
      expect(@array_of_hashes.extract_hashes(:a, :b){|sub_hash| sub_hash[:a] = sub_hash[:a]*2 }).to eq [ {:a => 2, :b => 2}, {:a => 8, :b => 5} ]
    end
    
  end
  
  describe 'extract_hash_values' do
    
    it 'extracts values of a given key from an array of hashes' do
      array_of_hashes = [ {:a => 1, :b => 2}, {:a => 3, :b => 4} ]
      expect(array_of_hashes.extract_hash_values(:a)).to eq [1,3]
    end
    
  end
  
  describe 'change_hash_values' do
    
    it 'changes values of a given key in an array of hash' do
      array_of_hashes = [ {:a => 1, :b => 2}, {:a => 3, :b => 4} ]
      expect(array_of_hashes.change_hash_values(:a){|value| value*2}).to eq [ {:a => 2, :b => 2}, {:a => 6, :b => 4} ]
    end
    
  end     
  
end  