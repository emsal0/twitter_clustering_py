import sys

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import selenium.webdriver.support.ui as ui
from selenium.webdriver.common.by import By
import selenium.webdriver.support.expected_conditions as EC

import time

from bs4 import BeautifulSoup

def scroll_to_bottom(browser):
    last_height = browser.execute_script("return document.body.scrollHeight;")
    # num_cards = len(browser.find_elements_by_class_name("ProfileCard"))

    while True:
        browser.execute_script("window.scrollTo(0, document.body.scrollHeight);")

        time.sleep(0.5)

        # new_num_cards = len(browser.find_elements_by_class_name("ProfileCard"))
        new_height = browser.execute_script("return document.body.scrollHeight;") 
        if new_height == last_height:
            break
        last_height = new_height



def get_follow_list(username, your_username, password):
    browser = webdriver.Firefox()

    browser.get("https://twitter.com/{username}/following".format(**{'username' : username}))

    username_field = browser.find_element_by_class_name("js-username-field")
    password_field = browser.find_element_by_class_name("js-password-field")

    username_field.send_keys(your_username)
    password_field.send_keys(password)

    ui.WebDriverWait(browser, 5)
    password_field.send_keys(Keys.RETURN)

    ui.WebDriverWait(browser, 10).until(EC.presence_of_element_located((By.CLASS_NAME, "ProfileCard")))

    # scroll_to_bottom(browser)
    last_height = browser.execute_script("return document.body.scrollHeight;")
    # num_cards = len(browser.find_elements_by_class_name("ProfileCard"))

    while True:
        browser.execute_script("window.scrollTo(0, document.body.scrollHeight);")

        time.sleep(0.5)

        # new_num_cards = len(browser.find_elements_by_class_name("ProfileCard"))
        new_height = browser.execute_script("return document.body.scrollHeight;") 
        if new_height == last_height:
            break
        last_height = new_height


    ui.WebDriverWait(browser, 3000)

    ret = browser.execute_script("return document.documentElement.innerHTML;")
    browser.close()
    soup = BeautifulSoup(ret, 'html.parser')
    cards = soup.findAll("div", {"class": "ProfileCard"})
    screennames = [card.get("data-screen-name") for card in cards]

    return screennames

if __name__ == "__main__":

    print(get_follow_list(sys.argv[1], sys.argv[2], sys.argv[3]))
