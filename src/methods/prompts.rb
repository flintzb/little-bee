require_relative '../classes/class_user'
require_relative '../classes/class_child'

def retrieve_profile
  # get response
  response_name = PROMPT.ask('What is your name? (Case Sensitive)'.colorize(:magenta).on_light_white, required: true)
  exit if response_name.downcase == 'exit' || response_name.downcase == 'quit'
  # get complete list to compare response to
  all_names = User.class_variable_get(:@@all_names)
  # Is there a value that matches the response?
  if all_names.value?(response_name)
    # What's the id of the listing that has the value?
    current_id = all_names.key(response_name)
    # Return the id for later use
    puts 'Account Found!'.colorize(:green).on_light_white
    current_id
  else
    puts 'No account found! Try again.'.colorize(:red).on_light_white
    nil
  end
end

def check_pass(profile)
  # get response
  response_pass = PROMPT.mask('What is your password? (Case Sensitive)'.colorize(:magenta).on_light_white,
                              required: true)
  # get password hash
  all_passwords = User.class_variable_get(:@@all_passwords)
  # compare value of password associated with the retrieved id from previous function.
  id = profile
  if response_pass == all_passwords.fetch(id)
    puts 'Confirmed!'.colorize(:green).on_light_white
    true
  else
    puts 'No such account.'.colorize(:red).on_light_white
  end
end

def navigate_main
  PROMPT.select('What would you like to do?'.colorize(:magenta).on_light_white) do |menu|
    menu.enum '.'
    menu.choice 'VIEW CHILDREN', 1
    menu.choice 'EXIT APPLICATION', 2
  end
end

def retrieve_children
  while true
    # Ask client how they would like the children sorted.
    nav = PROMPT.select('Sort by:'.colorize(:magenta).on_light_white, active_color: :red) do |menu|
      menu.choice name: 'NAME', value: 1
      menu.choice name: 'ID', value: 2
      menu.choice name: 'ROOM', value: 3
      menu.choice name: 'BACK', value: 4
      menu.choice name: 'EXIT', value: 5
    end

    return 'BACK' if nav == 4

    exit if nav == 5

    child = select_sorted_children(nav)
    next if child == 'BACK'

    return child
  end
end

def select_sorted_children(nav)
  while true
    # Set up a new array with the value "BACK" to be populated with the children, sorted in some manner.
    sorted = ['BACK']
    # Set up a string to identify which way it has been sorted through.
    sorted_by = ''

    selection = ''
    # Sort children depending on response.

    case nav

    # Sort alphabetically by name
    when 1
      unsorted = ChildProfile.class_variable_get(:@@child_by_name)
      sorted.push(sort(unsorted))
      sorted_by = 'NAME'

    # Sort numerically by ID.
    when 2
      unsorted = ChildProfile.class_variable_get(:@@child_by_id)
      sorted.push(unsorted.map { |list| 'ID: ' + list[0].to_s + ' | ' + list[1] })
      sorted_by = 'ID'

    # Sort by age.
    when 3
      sorted_by = 'ROOM'
      sort_nav = PROMPT.select('Select which room:'.colorize(:magenta).on_light_white, active_color: :red) do |menu|
        menu.choice name: 'KOALA (0-1 YEARS)', value: 1
        menu.choice name: 'ECHIDNA (2-3 YEARS)', value: 2
        menu.choice name: 'JOEY (4-6 YEARS)', value: 3
        menu.choice name: 'BACK', value: 5
        menu.choice name: 'EXIT', value: 6
      end

      sorted_room = ['BACK']
      by_room = ''
      age_min = 0
      age_max = 0
      # Appropriate sorting by client response.
      case sort_nav

      # Show children between 0 and 1 years.
      when 1
        by_room = 'KOALA'
        age_min = 0
        age_max = 1

      # Show children between 2 and 3 years.
      when 2
        by_room = 'ECHIDNA'
        age_min = 2
        age_max = 3

      # Show children between 4 and 5 years.
      when 3
        by_room = 'JOEY'
        age_min = 4
        age_max = 5

      # Return to previous menu.
      when 5
        return 'BACK'

      # exit application
      when 6
        exit
      end

      # each child object has @age paramater, sort @age between x < age < y into respective rooms.
      filtered = ChildProfile.class_variable_get(:@@children).select do |child|
        child.age[:year] >= age_min && child.age[:year] <= age_max
      end
      filtered = filtered.sort do |one, two|
        (one.age[:year] * 12) + one.age[:month] + (one.age[:day] / 100.0) <=> (two.age[:year] * 12) + two.age[:month] + (two.age[:day] / 100.0)
      end
      sorted.push filtered.map { |child|
        "#{child.name}, #{child.age[:year]} years, #{child.age[:month]} months and #{child.age[:day]} days old."
      }
    when 4
      return 'BACK'
    end

    selection = PROMPT.select("Viewing children by #{sorted_by}:".colorize(:magenta).on_light_white, sorted, filter: true, per_page: 10,
                                                                                                             active_color: :red)
    return 'BACK' if selection == 'BACK'

    selected_child = nil
    case sorted_by
    when 'NAME'
      selected_child = ChildProfile.class_variable_get(:@@children).find { |child| child.name == selection }
    when 'ID'
      proper_name = selection.split(' | ')[1]
      selected_child = ChildProfile.class_variable_get(:@@children).find { |child| child.name == proper_name }
    when 'ROOM'
      proper_name = selection.split(', ')[0]
      selected_child = ChildProfile.class_variable_get(:@@children).find { |child| child.name == proper_name }
    end
    return selected_child
  end
end

def sort(value)
  return value.sort
end