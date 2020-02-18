require 'net/http'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
    @start = Time.now
  end

  def score
    @answer = params[:answer].upcase
    letters = params[:letters]
    grid = params[:letters].split
    end_time = Time.now
    start_time = params[:start_time]
    @p_score = 0
    time = ((end_time.to_i - start_time.to_i) / 100_000_000) ^ 2
    @comment = if english_word?(@answer) && in_grid?(@answer, grid)
                 @p_score = (@answer.length * 10) - time
                 "Congratulations! #{@answer.upcase} is a valid English word!"
               elsif english_word?(@answer)
                 "Sorry but #{@answer} can't be built out of #{letters}"
               else
                 "Sorry but #{@answer} doesn't seem to be an English word"
               end
    if session[:score].present?
      session[:score] += @p_score
    else
      session[:score] = @p_score
    end
    @total_score = session[:score]
  end

  def result(answer, grid)
    if english_word?(@answer) && in_grid?(answer, grid)
      @p_score = (answer.length * 10) - time
      "Congratulations! #{answer.upcase} is a valid English word!"
    elsif english_word?(answer)
      "Sorry but #{answer} can't be built out of #{letters}"
    else
      "Sorry but #{answer} doesn't seem to be an English word"
    end
  end

  def english_word?(answer)
    url = "https://wagon-dictionary.herokuapp.com/#{answer}"
    uri = URI(url)
    result_ser = Net::HTTP.get(uri)
    result = JSON.parse(result_ser)
    result['found']
  end

  def in_grid?(answer, letters)
    hash_answer = Hash.new(0)
    hash_letters = Hash.new(0)
    answer.upcase.chars.each { |l| hash_answer[l] += 1 }
    letters.each { |l| hash_letters[l] += 1 }
    answer.upcase.chars.all? { |l| hash_answer[l] <= hash_letters[l] }
  end
end
