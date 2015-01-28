# By default Volt generates this controller for your Main component
class MainController < Volt::ModelController
  def index
    # Add code for when the index view is loaded
    page._start_path = 'main/main/path_display'
  end

  def about
    # Add code for when the about view is loaded
  end

  def path_parts
    page._the_path.or('missing').split('/')
  end

  def preview_path
    check_path = page._the_path.or('').gsub(/\/$/, '')
    if ['main/main', 'main'].include?(check_path)
      return 'missing'
    else
      return page._the_path
    end
  end

  def match_parts
    view_lookup = Volt::ViewLookupForPath.new($page, page._start_path.or('main/main/path_display'))

    parts = path_parts
    parts_size = parts.size

    possible_paths = []

    default_parts = ['main', 'main', 'index', 'body']

    match_path, _ = view_lookup.path_for_template(page._the_path.or('missing'))

    matched_a_path = false

    (5 - parts_size).times do |path_position|
      full_path = [nil, nil, nil, nil]

      start_at = full_path.size - parts_size - path_position

      full_path.size.times do |index|
        if index >= start_at
          if (part = parts[index - start_at])
            full_path[index] = part
          else
            full_path[index] = 'default:' + default_parts[index]
          end
        end
      end

      # Check the generated match path against the actual matched path
      gen_path = full_path.compact.map {|v| v.gsub(/^default:/, '')}.join('/')
      match = (match_path && match_path[(-1 * gen_path.size)..-1] == gen_path)

      matched_a_path = true if match

      possible_paths << ([match] + full_path)
    end

    return possible_paths, matched_a_path
  end

  private

  # The main template contains a #template binding that shows another
  # template.  This is the path to that template.  It may change based
  # on the params._controller and params._action values.
  def main_path
    'path_display'
  end

  # Determine if the current nav component is the active one by looking
  # at the first part of the url against the href attribute.
  def active_tab?
    url.path.split('/')[1] == attrs.href.split('/')[1]
  end
end
