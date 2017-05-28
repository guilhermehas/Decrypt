#
# Author: Daniel Adornes
# Date: 03/30/2013
# 

class CodeBreaker

  attr_accessor(:cipher_text, :key_length, :key)

  def initialize(cipher_text)
    self.cipher_text = cipher_text
  end

  def decrypt
    
    # Find out the key length, unless it is already set
    @key_length = find_key_length unless @key_length
    
    # Find out the key based on frequency analysis, unless it is already set
    @key = find_key unless @key
    
    # Find out and return plain text
    find_plain_text
  end
  

  private

  @@ALPHABET = "abcdefghijklmnopqrstuvwxyz"

  def find_key_length

    # Search for blocks repetitions, starting with blocks of length 20, down to 3
    20.downto(3) do |block_length|
      
      blocks = find_block_repetitions( block_length )
      
      # Find repetitions whose distances have common divisor
      blocks.each_pair do |block, occurrencies|
        
        # Consider only blocks that repeat more than 10 times
        if occurrencies > 10

          # Find positions index for each block
          idx_occurrencies = find_occurrencies_position(block, occurrencies)
          
          # Test possible key lengths from 30 to 4
          # by looking for perfect division (mod zero for all cases)
          30.downto(4) do |possible_key_length|
            divisable = true
            
            (idx_occurrencies.length-1).downto(1) do |i|
              if (idx_occurrencies[i] - idx_occurrencies[i-1]) % possible_key_length != 0
                divisable = false
                break
              end
            end
            
            # Assumes the key length was found when all distances between occurrences of a given block
            # are perfectly divisable by the same number
            if divisable
              puts "Key length found: #{possible_key_length}"
              return possible_key_length
            end
          end
        end
      end
    end

    raise "Failed to find key length!"
  end

  
  def find_key

    @key = Array.new

    # Chooses 'e' char as the base char for frequency analysis
    base_char_for_frequency_analysis = 'e'
    idx_base_char = @@ALPHABET.index(base_char_for_frequency_analysis)
    
    # Iterates up to the key length
    (0...@key_length).each do |key_position|
      
      # Builds the cipher text slice
      cipher_text_slice = build_cipher_text_slice( key_position )
      
      # Frequency analysis
      encrypted_e = find_more_frequent_char( cipher_text_slice )
      
      # Stores the key char index
      @key[key_position] = (@@ALPHABET.index(encrypted_e) - idx_base_char + @@ALPHABET.length) % @@ALPHABET.length
              
    end
    
    # Output the Key
    str_key = @key.map{|i| @@ALPHABET[i]}.join
    puts "Key found: #{str_key}"
    
    @key
  end

  
  def find_plain_text
    plain_text = String.new
    
    # Iterates through each position of the cipher text
    (0...@cipher_text.length).each do |i|
      # Finds the key index to use for decryption
      idx_key = @key[i % @key.length]

      # Finds the cipher char index
      idx_cipher_char = @@ALPHABET.index(@cipher_text[i])

      # Finds the plain text char index
      idx_plain = (idx_cipher_char - idx_key + @@ALPHABET.length) % @@ALPHABET.length
      
      # Append the plain text char to plain text variable
      plain_text << @@ALPHABET[idx_plain]
    end
    
    plain_text
  end


  def find_block_repetitions ( block_length )
    blocks = Hash.new
      
    (0..(@cipher_text.length-block_length)).each do |i|
      block = @cipher_text[i,block_length]
      
      c = blocks.include?(block) ? blocks[block] + 1 : 1
      blocks[block] = c
    end

    blocks
  end


  def find_occurrencies_position( block, occurrencies )
    idx_occurrencies = Array.new

    position = 0
    idx = 0
    while idx < occurrencies do
      position = @cipher_text.index(block, position)
      break unless position
      
      idx_occurrencies[idx] = position
      idx += 1
      position += 1          
    end

    idx_occurrencies
  end


  def build_cipher_text_slice( position )
    cipher_text_slice = String.new
      
    (position...(@cipher_text.length)).step(@key_length) do |i|
      cipher_text_slice << @cipher_text[i]
    end

    cipher_text_slice
  end


  def find_more_frequent_char( cipher_text_slice )
    # Count frequency of each character in the cipher text slice
    char_freqs = cipher_text_slice.chars.to_a.inject(Hash.new(0)) { |f, c| f[c] += 1 ; f }
    
    # Finds the more frequent char in the current cipher text slice
    # in order to infer the 'e' correspondent encrypted char
    char_freqs.max_by{|ch, freq| freq }.first
  end
end
