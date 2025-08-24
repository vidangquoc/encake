class CommonWordMeaning < ActiveRecord::Base
  
  strip_attributes collapse_spaces: true
  
  TYPES = {
    n:      'Noun',
    prn:    'Proper Name',
    pron:   'Pronoun',
    adj:    'Adjective',
    art:    'Article',
    v:      'Verb',
    vi:     'Intransitive Verb',
    vt:     'Transitive Verb',
    adv:    'Adverb',
    conj:   'Conjunction',
    interj: 'Interjection',
    prep:   'Preposition',
    exp:    'Expression'
  }
  
  POPULARITIES = {
    1 => 'Popular',
    2 => 'Rather Popular',
    3 => 'Rare',
    4 => 'Very Rare'
  }
  
  validates :common_word_id, {
    :presence => true
  }
  
  validates :content, {
    :presence => true
  }
  
  validates :meaning, {
    :presence => true
  }
  
  belongs_to :common_word
  belongs_to :common_word_meaning_group
  
  def specify_type()
    update_attribute :word_type, self.class.convert_type(type_name)
  end
  
  def get_official_type
    if ['vi', 'vt', 'v'].include? word_type
      'v'
    else
      word_type
    end
  end
  
end

class << CommonWordMeaning
  
  def convert_type(name)
    
    case name
    when /nội động từ/, /Intransitive Verb/ then "vi"
    when /ngoại động từ/, /Transitive Verb/ then "vt"
    when /động từ/, /Verb/ then "v"
    when /tính từ chỉ định/, /Demonstrative Adjective/ then "dadj"
    when /tính từ/, /Adjective/ then "adj"
    when /danh từ/, /Noun/ then "n"
    when /liên từ/, /Conjunction/ then "conj"
    when /giới từ/, /Preposition/ then "prep"
    when /phó từ/, /Adverb/ then "adv"
    when /mạo từ/, /Article/ then "art"
    when /đại từ/, /Pronoun/ then "pron"
    when /thán từ/, /Interjection/ then "interj"
    when /định ngữ/ then "exp"
    end
    
  end
  
end
