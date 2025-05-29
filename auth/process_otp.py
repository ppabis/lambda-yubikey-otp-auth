import yubico_client.modhex as modhex
from Cryptodome.Cipher import AES
import re

class OTP:
    def __init__(self, otp: str):
        if not re.match(r'^[cbdefghijklnrtuv]{44}$', otp):
            raise Exception("Invalid OTP format")
        self.source_otp = otp
        self.public_id = otp[:12]
        m_private_part = otp[12:]
        m_hex_private = list(modhex.translate(m_private_part, modhex.HEX))[0]
        self.private_part = bytes.fromhex(m_hex_private)
        self.decrypted = None
        self.private_id = None
        self.usage_counter = -1
        self.timestamp = -1
        self.session_counter = -1
        self.combined_counter = -1
        self.random = None
        self.checksum = None

    def decrypt(self, key: bytes):
        self.decrypted = AES.new(key, AES.MODE_ECB).decrypt(self.private_part)
        self.private_id = self.decrypted[:6]
        self.usage_counter = int.from_bytes(self.decrypted[6:8], byteorder='little', signed=False)
        self.timestamp = int.from_bytes(self.decrypted[8:11], byteorder='little', signed=False)
        self.session_counter = int.from_bytes(self.decrypted[11:12], byteorder='little', signed=False)
        self.random = self.decrypted[12:14]
        self.checksum = self.decrypted[14:16]
        self.combined_counter = self.usage_counter * 1000 + self.session_counter
    
    def validate(self, expected_private: bytes, last_counter: int) -> bool:
        """
        Source: https://github.com/Yubico/python-pyhsm/blob/master/pyhsm/soft_hsm.py#L132
        """
        m_crc = 0xffff
        for this in self.decrypted:
            m_crc ^= this
            for _ in range(8):
                j = m_crc & 1
                m_crc >>= 1
                if j:
                    m_crc ^= 0x8408
        
        return m_crc == 0xf0b8 \
          and expected_private == self.private_id \
          and self.combined_counter > last_counter
    
    def __str__(self):
        if self.decrypted is None:
            return f"""
            {'Public ID:':<17} {self.public_id}
            OTP not decrypted yet
            """
        return f"""
        {'Public ID:':<17} {self.public_id}
        {'Private ID:':<17} {self.private_id.hex(":")}
        {'Usage Counter:':<17} {self.usage_counter}
        {'Timestamp:':<17} {self.timestamp}
        {'Session Counter:':<17} {self.session_counter}
        {'Random:':<17} {self.random.hex(":")}
        {'Checksum:':<17} {self.checksum.hex(":")}
        """