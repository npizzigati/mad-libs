require 'sinatra'
require 'bundler/setup'
require_relative './lib/mad_libs.rb'

before do
  @prestory = choose_random_story
end

get '/' do
  descriptors = extract(@prestory)
  @prompts = assemble_prompts(descriptors)
  erb :questions
end

post '/' do
  fill_in_blanks(@prestory, params[:answers])
end
