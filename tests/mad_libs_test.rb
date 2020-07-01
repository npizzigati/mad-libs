require 'minitest/autorun'
require_relative '../lib/mad_libs.rb'
require_relative './test_helper.rb'
include IoTestHelpers

class MadlibTest < Minitest::Test
  def test_extract
    prestory = <<~TEXT
      I had a ((an adjective)) sandwich for lunch today.               
      It dripped all over my ((a body part)) and ((a noun)).
    TEXT
    expected = ['an adjective', 'a body part', 'a noun']
    actual = extract(prestory)
    assert_equal(expected, actual)
  end

  def test_assemble_prompts
    descriptors = ['adj1: an adjective', 'a body part',
                   'adj1', 'a noun'] 
    expected = [{ name: 'an adjective', positions: [0, 2] },
                { name: 'a body part', positions: [1] },
                { name: 'a noun', positions: [3] }]     
    actual = assemble_prompts(descriptors)
    assert_equal(expected, actual)
  end

  def test_obtain_words
    blanks = ['adj1: an adjective', 'a body part', 'adj1', 'a noun']
    user_input = ['smelly', 'nose', 'kitchen']
    expected = ['smelly', 'nose', 'smelly', 'kitchen']
    actual = simulate_stdin(*user_input) { obtain_words(blanks) }
    assert_equal(expected, actual)
  end

  def test_extract_parts
    original = 'gem: a gemstone'
    expected = ['gem', 'a gemstone']
    actual = extract_parts(original)
    assert_equal(expected, actual)
  end

  def test_has_variable_name?
    original = 'an adjective'
    expected = false
    actual = has_variable_name?(original)
    assert_equal(expected, actual)
  end

  def test_user_input
    input = 'filthy'
    descriptor = 'an adjective'
    expected = 'filthy'
    actual = simulate_stdin(input) { user_input(descriptor) }
    assert_equal(expected, actual)
  end

  def test_fill_in_blanks
    expected = 'I had a smelly sandwich for lunch today. ' \
               'It dripped all over my nose and smelly kitchen'
    story    = 'I had a ((adj1: an adjective)) sandwich for lunch today. ' \
               'It dripped all over my ((a body part)) and ' \
               '((adj1)) ((noun))'
    replacements = %w(smelly nose smelly kitchen)
    actual = fill_in_blanks(story, replacements)
    assert_equal(expected, actual)
  end

  def test_account_for_punctuation
    expected = 'I had a smelly, gross sandwich for lunch today. ' \
               'It dripped all over my nose and smelly kitchen'
    story    = 'I had a ((adj1: an adjective)), ((an adjective)) sandwich for lunch today. ' \
               'It dripped all over my ((a body part)) and ' \
               '((adj1)) ((noun))'
    replacements = %w(smelly gross nose smelly kitchen)
    actual = fill_in_blanks(story, replacements)
    assert_equal(expected, actual)
  end
end
