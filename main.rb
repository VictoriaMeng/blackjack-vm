require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'random_string' 

 BLACKJACK_VALUE = 21
 DEALER_STAY_VALUE = 17

helpers do 
	def hand_total(hand)
		total = 0
		hand.each do |card| 
			total += card[0][1]
		end
		hand.select{|card| card[0][1] == 11}.count.times do
			break if total <= BLACKJACK_VALUE
			total -= 10
		end
		total
	end

	def get_image(card)
		"<img src='/images/cards/#{card[1].downcase}_#{card[0][0].downcase}.jpg'>"
	end
end

get "/" do
	if session[:player_name]
		redirect "/bet"
	else
		redirect "/name_form"
	end
end

get "/name_form" do
	erb :name_form
end

post "/post_name" do
	session[:player_name] = params[:player_name]
	session[:money] = 500.to_f
	redirect "/bet"
end

get "/bet" do
	erb :bet
end

post "/make_bet" do
	session[:bet] = params[:bet].to_f
	redirect "/game"
end

get "/game" do
	suits = ["Clubs", "Diamonds", "Hearts", "Spades"]
	cards = [["Ace", 11], ["2", 2], ["3", 3], ["4", 4], ["5", 5], ["6", 6], ["7", 7], ["8", 8], ["9", 9], ["10", 10], ["Jack", 10], ["Queen", 10], ["King", 10]]
	
	
	session[:deck] = cards.product(suits).shuffle!
	session[:game_state] = "player_turn"
	session[:player_status] = "player_solvent"

	session[:player_hand] = []
	session[:dealer_hand] = []

	2.times do
		session[:player_hand] << session[:deck].pop
		session[:dealer_hand] << session[:deck].pop
	end

	player_total = hand_total(session[:player_hand])
	dealer_total = hand_total(session[:dealer_hand])

	session[:game_state] = "player_blackjack" if player_total == BLACKJACK_VALUE
	session[:game_state] = "dealer_blackjack" if dealer_total == BLACKJACK_VALUE

	if session[:game_state] == "player_blackjack"
		session[:money] += session[:bet]*1.5
	elsif session[:game_state] == "dealer_blackjack"
		session[:money] -= session[:bet]*1.5
	end

	session[:player_status] = "player_broke" if session[:money] <= 0

	erb :game
end

get "/hit_or_stay" do
	dealer_total = hand_total(session[:dealer_hand])

	if params[:hit_or_stay] == "hit"
		session[:player_hand] << session[:deck].pop
		player_total = hand_total(session[:player_hand])
		session[:game_state] = "player_bust" if player_total > BLACKJACK_VALUE
	elsif params[:hit_or_stay] == "stay"
		player_total = hand_total(session[:player_hand])
		session[:game_state] = "dealer_turn" if dealer_total < DEALER_STAY_VALUE
		if dealer_total >= DEALER_STAY_VALUE && dealer_total < player_total
			session[:game_state] = "player_win" 
		elsif dealer_total >= DEALER_STAY_VALUE && dealer_total > player_total
			session[:game_state] = "dealer_win"
		elsif dealer_total >= DEALER_STAY_VALUE && dealer_total == player_total
			session[:game_state] = "push"
		end
	end

	if session[:game_state] == "player_win" 
		session[:money] += session[:bet]
	elsif session[:game_state] == "dealer_win" || session[:game_state] == "player_bust"
		session[:money] -= session[:bet]
	end

	session[:player_status] = "player_broke" if session[:money] <= 0
		
	erb :game, layout: false
end

get "/play_again" do
	redirect "/bet" if params[:play_again] == "play_again"
end

get "/dealer_card" do
	session[:dealer_hand] << session[:deck].pop

	player_total = hand_total(session[:player_hand])
	dealer_total = hand_total(session[:dealer_hand])

	session[:game_state] = "dealer_bust" if dealer_total > BLACKJACK_VALUE
	if dealer_total <= BLACKJACK_VALUE
		if dealer_total >= DEALER_STAY_VALUE && dealer_total < player_total
			session[:game_state] = "player_win" 
		elsif dealer_total >= DEALER_STAY_VALUE && dealer_total > player_total
			session[:game_state] = "dealer_win"
		elsif dealer_total >= DEALER_STAY_VALUE && dealer_total == player_total
			session[:game_state] = "tie"
		end
	end

	if session[:game_state] == "player_win" || session[:game_state] == "dealer_bust"
		session[:money] += session[:bet]
	elsif session[:game_state] == "dealer_win"
		session[:money] -= session[:bet]
	end

	session[:player_status] = "player_broke" if session[:money] <= 0

	erb :game, layout: false
end
		