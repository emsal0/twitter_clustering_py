import sys

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import selenium.webdriver.support.ui as ui
from selenium.webdriver.common.by import By
import selenium.webdriver.support.expected_conditions as EC

import time

from bs4 import BeautifulSoup

class new_height_reached(object):
    def __init__(self, last_height):
        self.last_height = last_height

    def __call__(self, driver):
        new_height = driver.execute_script("return document.body.scrollHeight;")
        if new_height != self.last_height:
            return new_height
        else:
            return False



def get_follow_list(username, your_username, password):
    browser = webdriver.Firefox()

    browser.get("https://twitter.com/{username}/following".format(**{'username' : username}))

    username_field = browser.find_element_by_class_name("js-username-field")
    password_field = browser.find_element_by_class_name("js-password-field")

    username_field.send_keys(your_username)
    password_field.send_keys(password)

    ui.WebDriverWait(browser, 5)
    password_field.send_keys(Keys.RETURN)

    try:
        ui.WebDriverWait(browser, 10).until(EC.presence_of_element_located((By.CLASS_NAME, "ProfileCard")))
    except:
        return []


    last_height = browser.execute_script("return document.body.scrollHeight;")
    num_cards = len(browser.find_elements_by_class_name("ProfileCard"))
    while True:
        browser.execute_script("window.scrollTo(0, document.body.scrollHeight)");

        try:
            new_height = ui.WebDriverWait(browser, 1.5).until(new_height_reached(last_height))
            last_height = new_height
        except:
            # print(sys.exc_info())
            break

    print("Loop exited; follow list extracted")

    ret = browser.execute_script("return document.documentElement.innerHTML;")
    browser.close()
    soup = BeautifulSoup(ret, 'html.parser')
    cards = soup.findAll("div", {"class": "ProfileCard"})
    screennames = [card.get("data-screen-name") for card in cards]

    return screennames

if __name__ == "__main__":

    print(get_follow_list(sys.argv[1], sys.argv[2], sys.argv[3]))
