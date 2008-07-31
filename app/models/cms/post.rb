module CMS
  # Posts are CRUDed Contents
  # (CRUD: http://en.wikipedia.org/wiki/Create,_read,_update_and_delete)
  #
  # A Post is created when an Agent posts a Content to a Container
  class Post < ActiveRecord::Base
    set_table_name "cms_posts"

    acts_as_sortable
    acts_as_container :name => :title

    # Pagination (will_paginate gem)
    cattr_reader :per_page
    @@per_page = 15

    # Collection name
    # See CMS::Content
    cattr_reader :collection
    @@collection = :posts

    belongs_to :content,   :polymorphic => true
    belongs_to :container, :polymorphic => true
    belongs_to :agent,     :polymorphic => true

    has_many :categorizations,
             :class_name => "CMS::Categorization",
             :dependent => :destroy
    has_many :categories,
             :through => :categorizations


    validates_presence_of :title, 
                          :agent_id,
                          :agent_type,
                          :content_id, 
                          :content_type,
                          :container_id, 
                          :container_type
    validates_associated  :content


    # True if the associated Content of this Post has media
    def has_media?
      ! content.content_options[:has_media].nil?
    end

    # Can the Post be read by <tt>agent</tt>?
    def read_by?(agent = :false)
      public_read? || container.has_role_for?(agent, :admin) || container.has_role_for?(agent, :read_posts)
    end

    # Can the Post be modified by <tt>agent</tt>?
    def update_by?(agent = :false)
      public_write? || container.has_role_for?(agent, :admin) || container.has_role_for?(agent, :update_posts)
    end

    # Set Post Categories by it id
    def category_ids=(cids)
      cids ||= []
      #FIXME: optimize
      categorizations.map(&:destroy)
      for cid in cids
        categories << CMS::Category.find(cid)
      end
    end

    # Converts "<cms/post>" to "<post>"
    def to_xml_with_remove_cms_prefix(options = {}, &block) #:nodoc:
      to_xml_without_remove_cms_prefix(options, &block).gsub(/cms\/post>/, "post>")
    end

    alias_method_chain :to_xml, :remove_cms_prefix
  end
end