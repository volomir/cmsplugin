class XhtmlText < ActiveRecord::Base
  validates_presence_of :text

  def self.atom_parser(entry)
    { :text => entry.content.xml.to_s }
  end
end
