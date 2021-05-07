import os
import traceback
import logging
from selenium import webdriver

def lambda_handler(event=None, context=None):

    opened: bool = False

    try:
        driver: webdriver.Chrome = get_chrome_driver()
        opened = True 
        driver.get(event['url'])
        return driver.find_element_by_xpath("//html").text
    except Exception as e:
        logging.error(traceback.format_exc())
    finally:
        # Ensure the Browser is closed.  This is recommended in case the underlying container that Lambda is running is re-used.
        if(opened):
            driver.quit()


def get_chrome_driver() -> webdriver.Chrome:

    # Get the Chrome Driver Configuration
    # The following configuration settings are required, to enable the use of Headless Chromium.
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')                  
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1280x1696')
    options.add_argument('--single-process')
    options.add_argument('--disable-extensions')
    options.add_argument('--disable-dev-shm-usage')
    options.binary_location = '/usr/local/headless-chromium'
    return webdriver.Chrome("/usr/local/chromedriver/chromedriver", options=options)
