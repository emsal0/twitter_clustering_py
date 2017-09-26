import sys

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import selenium.webdriver.support.ui as ui

def get_follow_list(username, your_username, password):
    browser = webdriver.Firefox()

    browser.get("https://twitter.com/{username}/following".format(**{'username' : username}))

    username_field = browser.find_element_by_class_name("js-username-field")
    password_field = browser.find_element_by_class_name("js-password-field")

    username_field.send_keys(your_username)
    password_field.send_keys(password)

    ui.WebDriverWait(browser, 5000)
    password_field.send_keys(Keys.RETURN)

    ui.WebDriverWait(browser, 5000)
    ret = browser.execute_script("return document.documentElement.outerHTML;")
    browser.close()
    return ret

if __name__ == "__main__":

    print(get_follow_list(sys.argv[1], sys.argv[2], sys.argv[3]))
