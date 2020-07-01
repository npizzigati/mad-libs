# This Ruby Quiz is to write a program that presents the user with that
# favorite childhood game, Mad Libs. Don’t worry if you have never
# played; it’s an easy game to learn. A Mad Libs is a story with several
# placeholders. For example:
# I had a ((an adjective)) sandwich for lunch today.

# It dripped all over my ((a body part)) and ((a noun)).

# The reader, the only person who sees the story, will ask another person
# for each placeholder in turn and record the answers. In this example,
# they would ask for an adjective, a body part, and a noun. The reader
# then reads the story, with the answers in place. It might come out
# something like this:

# I had a smelly sandwich for lunch today.
# It dripped all over my big toe and bathtub.

# Laughter ensues.
# The script should play the role of reader, asking the user for a series of
# words, then replacing placeholders in the story with the user’s answers.
# We’ll keep our story format very simple, using a ((...)) notation for place-
# holders. Here’s an example:
# Our favorite language is ((a gemstone)).
# If your program is fed that template, it should ask you to enter “a gem-
# stone” and then display your version of the story:
# Our favorite language is Ruby.
# That covers the simple cases, but in some instances we may want to
# reuse an answer. For that, we’ll introduce a way to name them:

# Our favorite language is ((gem:a gemstone)).
# We think ((gem)) is better than ((a gemstone)).

# With the previous story, your program should ask for two gemstones,
# then substitute the one designated by ((gem:...)) at ((gem)) . When there
# is a colon in the ((...)) , the part before the colon becomes the pointer to
# the reusable value, and the part after the colon is the prompt for the
# value. That would give results like this:

# Our favorite language is Ruby.
# We think Ruby is better than Emerald.

# You can choose any interface you like, as long as a user can interact
# with the end result. You can play around with a CGI-based solution at
# the Ruby Quiz site. 5 You can find the two Mad Libs files I’m using on
# the Ruby Quiz site as well. 6


# input: string of story passed as parameter; user interactively enters missing words
# output: string; prompts for missing words

# rules: "madlib" stories with each missing word to be filled in surrounded by double parentheses
#        words to be repeated are to have a variable: prefacing them
#        can use any sort of user interface

# algorithm:
# extract all missing word types
# get user's words for all missing words; store variable references
# initialie array to store variables bufore loop
# extract each term
# replace story fields with user words and variables, and output
require_relative '../resources/stories.rb'

# Picks random story
#
# @return [String] story
def choose_random_story
  Stories::STORIES.sample
end

# Extracts descriptors surrounded by double parentheses from prestory
#
# @params [String]
# @return [Array<String>] descriptors, without the parentheses
def extract(prestory)
  prestory.scan(/\(\((.+?)\)\)/).flatten
end

# Obtains words from user and propagates them to descriptor variables
#
# @param [Array<String>] descriptors
# @return [Array<String>] all words to fill in blanks, in order
def obtain_words(descriptors)
  variables = {}
  words = []

  descriptors.each do |descriptor|
    if variables.include?(descriptor)
      words << variables[descriptor]
    elsif has_variable_name?(descriptor)
      variable, term_type = extract_parts(descriptor)
      word = user_input(term_type)
      variables[variable] = word
      words << word
    else
      word = user_input(term_type)
      words << word
    end
  end
  words
end

# Extracts a list of prompts from descriptor list
#
# @param descriptors [Array<String>]
# @return [Array<String>]
# @example
# descriptors = ['adj1: an adjective', 'a body part',
#                'adj1', 'a noun'] 
# assemble_prompts(descriptors) = [{ name: 'an adjective', positions: [0, 2] },
#                                  { name: 'a body part', positions: [1] },
#                                  { name: 'a noun', positions: [3] }]     
def assemble_prompts(descriptors)
  prompts = []
  variables = {}
  descriptors.each_with_index do |descriptor, idx| 
    if has_variable_name?(descriptor)
      variable, term_type = extract_parts(descriptor)
      variables[variable] = idx
      prompts << { name: term_type, positions: [idx] }
    elsif variables.keys.include?(descriptor)
      original_prompt_idx = variables[descriptor]
      prompts[original_prompt_idx][:positions] << idx 
    else
      prompts << { name: descriptor, positions: [idx] }
    end
  end
  prompts
end

# Extracts variable and term type from 2 part descriptors
#
# @param [String]
# @return [Array<String>] variable, term_type
def extract_parts(string)
  string.match(/(^\w+): (.+)/)[1, 2]
end

# Determines if descriptor contains a variable name in addition to term type
# in the format variable: term_type
#
# @param [String] descriptor
# @return [Boolean]
def has_variable_name?(descriptor)
  descriptor.match?(/^\w+:/)
end

# Receives user's chosen word for term type
#
# @param [String] term_type
# @return [String] user's chosen word
def user_input(term_type)
  print "Enter #{term_type}"
  gets.chomp
end

# Replaces descriptor fields in story with user's words
#
# @param story [String] prestory (story with descriptors)
# @param replacements [Array<String>] user's chosen words
# @return [String] final story
def fill_in_blanks(story, replacements)
  result = []
  placeheld = story.gsub(/\(\(.*?\)\)/, '_placeholder_')
  placeheld.split.each do |word|
    if word.include?('_placeholder_')
      word.sub!(/_placeholder_/, replacements.shift)
    end
      result << word
  end
  result.join(' ')

end
