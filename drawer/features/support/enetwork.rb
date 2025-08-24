module EnetworkActions
  
  def fillin(field, value)
    fill_in field, :with  => value
  end
  
  def select(select_field_name, value)
    find(:select, select_field_name).find(:option,value).select_option
  end   
  
  def click(target)
    click_on target
  end
  
  def scroll_to_and_click(element)
    page.execute_script("window.scrollTo(#{element.native.location.x}, #{element.native.location.y - 200})")
    element.click
  end
  
  def scroll_to_element(element, offset_top = 200)
    page.execute_script("window.scrollTo(#{element.native.location.x}, #{element.native.location.y - offset_top})")
  end
   
  def check_bootstrap_button(target)
   
    page.execute_script(%{
                                                  
      var target_elm = $('##{target}, [name=#{target}]');
      
      if( target_elm.length != 1 ) throw ('None or multi elements exist with id or name "#{target}"');
            
      if ( !target_elm.is(':checked') )  target_elm.closest('label.btn').click();
        
    })
    
  end
  
  def uncheck_bootstrap_button(target)
    
    page.execute_script(%{
                                                  
      var target_elm = $('##{target}, [name=#{target}]');
      
      if( target_elm.length != 1 ) throw ('None or multi elements exist with id or name "#{target}"');
           
      if (target_elm.is(':checked'))  target_elm.closest('label.btn').click();
                          
    })
    
  end
  
  private
  
  def show_element(target)
    page.execute_script(" $('##{target}, [name=#{target}]').show() ")
  end  
  
end

module EnetworkHelpers
  
  def has_error_on(field_name, error_type)
    expect(page).to have_css("##{field_name}_#{error_type}_error")    
  end
  
  def has_tag_with_text(tag,text)
    expect(page).to have_xpath("//#{tag}[text()='#{text}']")
  end
  
  def has_tag_with_attributes(tag,attributes_hash)    
    expect(page).to have_xpath("//#{tag}[#{ attributes_hash.map{|attr, value| "@#{attr}='#{value}'" }.join(" and ") }]")
  end
  
  def not_have_tag_with_attributes(tag,attributes_hash, container_selector = nil)
    expect(page).not_to have_xpath("//#{container_selector.nil? ? '' : container_selector } #{tag}[#{ attributes_hash.map{|attr, value| "@#{attr}='#{value}'" }.join(" and ") }]")
  end
  
  def has_link(attributes_hash)
    has_tag_with_attributes('a',attributes_hash)
  end
  
  def not_have_link(attributes_hash, container_selector = nil)
    not_have_tag_with_attributes('a',attributes_hash, container_selector)
  end
  
  def find_tag_with_attributes(tag,attributes_hash)    
    find(:xpath, "//#{tag}[#{ attributes_hash.map{|attr, value| "@#{attr}='#{value}'" }.join(" and ") }]")
  end
  
  def has_tag_with_id(tag, id)
    expect(page).to have_css "#{tag}##{id}"
  end  
  
end

module EnetworkFunctions
  
  def get_ids(class_name, id_attribute = 'data-id')
    page.all(".#{class_name}").map { |item| item[id_attribute] }.select{ |val| !val.blank? }.map(&:to_i)
  end
  
  def get_id(element_id, id_attribute = 'data-id')
    find("##{element_id}")[id_attribute].to_i
  end
  
  def get_text(element_id)
    find("##{element_id}").text()
  end
  
  def get_value(element_id)
    find("##{element_id}")['value']
  end
  
  def get_attribute_values(class_name, attribute_name)
    page.all(".#{class_name}").map { |item| item[attribute_name] }
  end
  
  def ajax_complete?   
    expect(page.document).to have_selector("body.ajax-completed")    
  end
  
  def get_texts(class_name)
    page.all(".#{class_name}").map { |item| item.text() }
  end
    
end

module EmailSpec::Helpers
  alias_method :links_in_email_old, :links_in_email
  def links_in_email(email)
    links_in_email_old(email).collect{|link| link.sub(/\'$/,'') }
  end  
end

World(EnetworkActions)
World(EnetworkHelpers)
World(EnetworkFunctions)
