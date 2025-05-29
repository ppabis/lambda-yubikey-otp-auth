from colorama import Fore, Style
from process_otp import OTP

TEST_PUBLIC_ID = "vvccccvblhlu"
TEST_PRIVATE_ID = bytes.fromhex("a4b67dc931a1")
TEST_AES_KEY = bytes.fromhex("c157d96a6b551f8b9414ab6d94b6a54c")

last_counter = 0

def pretty_print(otp: OTP):
    global last_counter
    print(otp)
    valid = otp.validate(TEST_PRIVATE_ID, last_counter)
    valid_formatted = f"{Fore.GREEN}Valid{Style.RESET_ALL}" if valid else f"{Fore.RED}Invalid{Style.RESET_ALL}"
    print(f"    {'Valid:':<17} {valid_formatted}")
    if valid:
        last_counter = otp.combined_counter
        print(f"{Fore.GREEN}New counter: {otp.combined_counter}{Style.RESET_ALL}")    
    print(f"{Style.DIM}--------------------------------{Style.RESET_ALL}")


if __name__ == "__main__":
    while True:
        otp = input("Enter OTP (or exit/quit): ")
        if otp.lower() in ["exit", "quit"]:
            break
        o = OTP(otp)
        o.decrypt(TEST_AES_KEY)
        pretty_print(o)
