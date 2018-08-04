feature Racker do
  background do
    visit '/'
  end

  scenario 'Visit index page' do
    expect(page).to have_content('A homefork for RG, rack task')
  end

  scenario 'Start new game' do
    click_link('New game')
    expect(page).to have_content('Game status: Playing')
  end

  scenario 'Try to guess code' do
    click_link('New game')
    fill_in('answer', with: '1111')
    click_button('Answer')
    expect(page).to have_selector('table.grid')
  end

  scenario 'Try to get hint' do
    click_link('New game')
    click_link('Take hint')
    expect(page).to have_content('A hint for you:')
    expect(page).not_to have_content('Take hint')
  end

  scenario 'Lose the game' do
    click_link('New game')
    5.times do
      fill_in('answer', with: '1111')
      click_button('Answer')
    end
    expect(page).to have_content('Game status: Game over')
  end
end
