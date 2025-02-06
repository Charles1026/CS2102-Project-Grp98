import csv
import sys
import random

MULTIPLES = [9, 4, 5, 4, 3, 2]
LETTERS = ['A', 'Z', 'Y', 'X', 'U', 'T', 'S', 'R', 'P', 'M', 'L', 'K', 'J', 'H', 'G', 'E', 'D', 'C', 'B']

if __name__ == "__main__":
  iterations = int(sys.argv[1])
  licenses = []
  for i in range(iterations):
    plateStr = "S"
    plate = []
    
    # Letters
    for j in range(2):
      val = random.randint(1, 26)
      plate.append(val)
      plateStr += chr(64 + val)
    
    # Numbers
    for j in range(4):
      val = random.randint(0, 9)
      plate.append(val)
      plateStr += chr(48 + val)
      
    # Checksum
    sum = 0
    for i in range(6):
      sum += plate[i] * MULTIPLES[i]
      
    plateStr += LETTERS[sum % 19]
    licenses.append(plateStr)
    
      
  with open('./license_plates.csv', 'w') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(licenses)


      
      
    