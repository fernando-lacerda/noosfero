class Kalibro::Entities::ProjectResult < Kalibro::Entities::Entity
  
  attr_accessor :project, :date, :load_time, :analysis_time, :source_tree

  def project=(value)
    @project = to_entity(value, Kalibro::Entities::Project)
  end

  def source_tree=(value)
    @source_tree = to_entity(value, Kalibro::Entities::ModuleNode)
  end

  def formatted_load_time
    format_milliseconds(@load_time)
  end

  def formatted_analysis_time
     format_milliseconds(@analysis_time)
  end

  def format_milliseconds(value)
    seconds = value.to_i/1000
    hours = seconds/3600
    seconds -= hours * 3600
    minutes = seconds/60
    seconds -= minutes * 60
    "#{format(hours)}:#{format(minutes)}:#{format(seconds)}"
  end

  def format(amount)
    ('%2d' % amount).sub(/\s/, '0')
  end

  def get_node(module_name)
    path = Kalibro::Entities::Module.parent_names(module_name)
    parent = @source_tree
    path.each do |node_name|
      parent = get_leaf_from(parent, node_name)
    end
    return parent
  end

  private
  def get_leaf_from(node, module_name) 
    node.children.each do |child_node|
      return child_node if child_node.module.name == module_name
    end
    nil
  end

end
