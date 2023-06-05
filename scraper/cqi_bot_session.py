from selenium import webdriver
from selenium.webdriver.common.by import By
from bs4 import BeautifulSoup
import pandas as pd
import time

login_email = 'erwintang91@gmail.com'
login_password = '7@N937n9CQI'

# open chromedriver
driver = webdriver.Chrome('C:\Program Files\Google\Chrome\Application\chromedriver.exe')

# navigate to login page
driver.get('https://database.coffeeinstitute.org/login')
time.sleep(5)

# submit login credentials 
form = driver.find_element(by=By.XPATH, value='//html/body/content[@class="scrollable"]/div[@class="container page"]/div[@class="form short"]/div[@class="login panel"]/form')
username = driver.find_element(by=By.NAME, value="username")
password = driver.find_element(by=By.NAME, value="password")
time.sleep(5)

username.send_keys(login_email)
password.send_keys(login_password)
driver.find_element(by=By.CLASS_NAME, value="submit").click()
time.sleep(5)


# navigate to coffees page, then to arabicas page containing links to all quality reports 
coffees = driver.find_element(by=By.XPATH, value='//html/body/header/nav[@id="main"]/div[@class="container"]/div[@class="in"]/a[@href="/coffees"]').click()
time.sleep(5)
driver.find_element(by=By.LINK_TEXT, value='Arabica Coffees').click()
time.sleep(5)

# these values can be changed if this breaks midway through collecting data to pick up close to where you left off
page = 2
coffee_idx = 100

while True:

	# 50 rows in these tables * 8 columns per row = 400 cells. Every 8th cell clicks through to that coffee's data page
	for i in range(0, 400, 8):
		time.sleep(5)

		# paginate back to the desired page number
		# don't think there's a way around this - the back() option goes too far back
		# some page numbers aren't available in the ui, but 'next' always is unless you've reached the end 
		for p_num in range(page):
			page_buttons = driver.find_elements(by=By.CLASS_NAME, value='paginate_button')
			page_buttons[-1].click() # the 'next' button
			time.sleep(5)
			page_buttons = driver.find_elements(by=By.CLASS_NAME, value='paginate_button')
			print(f'page: {page}')

		# select the cell to click through to the next coffee-data page
		time.sleep(5) # this next line errors out sometimes, maybe it needs more of a time buffer 
		table_cell=driver.find_elements(by=By.XPATH, value='//td')[i+1].click()
		text = driver.find_elements(by=By.XPATH, value='//td')[i+1].text
		time.sleep(5)
		tables = driver.find_elements(by=By.TAG_NAME, value="table")

		# loop over all coffee reports on the page, processing each one and writing to csv
		j = 0
		for tab in tables:
			try:
				t = BeautifulSoup(tab.get_attribute('outerHTML'), "html.parser")
				df = pd.read_html(str(t))
				name = f'coffee_{coffee_idx}_id_{text}_table_{j}_page_{page}.csv'
				df[0].to_csv(name)
				print(name)
				time.sleep(1)
			except Exception as e:
				print(f"Error processing table {name}: {e}")
			j += 1

		# return to main database coffee results page
		driver.get('https://database.coffeeinstitute.org/coffees/arabica')
		time.sleep(5)
		coffee_idx += 1

	page += 1
	if page == 4:
		break

# close the driver
driver.close()

