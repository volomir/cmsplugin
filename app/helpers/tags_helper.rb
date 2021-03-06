module TagsHelper
  def tag_list(taggable)
    returning "" do |html|
      html << "<div id=\"tag_list_#{ dom_id(taggable) }\" class=\"tag_list\">"
      html << "<strong>#{ t('tag.other') }</strong>: "
      html << taggable.tags.map { |t| 
        link_to(t.name, tag_path(t), :rel => "tag") }.join(", ")
      html << '</div>'
    end
  end
end
