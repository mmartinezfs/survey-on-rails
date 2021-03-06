require 'acceptance/acceptance_helper'

feature 'Take survey', %q{
  In order to know more about myself
  As a curious person with a lot of spare time
  I want to take a survey
} do

  background do
    @survey = Factory :survey
  end

  scenario "Survey with no questions" do
    visit survey_url @survey
    page.should have_no_link "Take survey!"
  end

  scenario 'Basic survey with 3 questions' do
    answers = 3.times.map do
      question = Factory :question, :survey => @survey
      Factory.build :answer, :question => question
    end

    visit survey_url @survey
    click_link "Take survey!"

    answers.each do |answer|
      fill_in answer.question.question, :with => answer.answer
      click_button "Create Answer"
    end

    page.should have_content "Thank you for taking this survey!"
    answers.each do |answer|
      page.should have_content answer.answer
    end
  end

  scenario 'Basic survey with 3 questions that is already taken' do
    answers = 3.times.map do
      question = Factory :question, :survey => @survey
      Factory.build :answer, :question => question
    end

    visit survey_url @survey
    click_link "Take survey!"

    answers.each do |answer|
      fill_in answer.question.question, :with => "old #{answer.answer}"
      click_button "Create Answer"
    end

    visit survey_url @survey
    click_link "Take survey!"

    answers.each do |answer|
      fill_in answer.question.question, :with => "new #{answer.answer}"
      click_button "Update Answer"
    end

    page.should have_content "Thank you for taking this survey!"
    answers.each do |answer|
      page.should have_content    "new #{answer.answer}"
      page.should have_no_content "old #{answer.answer}"
    end
  end
end
