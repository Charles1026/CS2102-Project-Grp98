l = ["S", "T", "F", "G", "M"][random(0, 4)];

year = if l == "S" || l == "F" then random(65, 99) elsif l == "T" then random(0, 25) elsif l == "G" then random(0, 21) else random(22, 25) end; 

year = if l == "S" && year < 68 then random(00, 19) else year end; #For pioneers before 1968 with nric 1 or 0

n1 = year / 10;
n2 = year % 10;
n3 = random(0, 9);
n4 = random(0, 9);
n5 = random(0, 9);
n6 = random(0, 9);
n7 = random(0, 9);

offset = if l == "G" || l == "T" then 4 elsif l == "M" then 3 else 0 end;
index = ((n1 * 2) + (n2 * 7) + (n3 * 6) + (n4 * 5) + (n5 * 4) + (n6 * 3)  + (n7 * 2) + offset) % 11;

index = if l == "M" then 10 - index else index end; # rotate index if M
  
checksum = if l == "S" || l == "T" then ["J", "Z", "I", "H", "G", "F", "E", "D", "C", "B", "A"][index] elsif l == "F" || l == 'G' then ["X", "W", "U", "T", "R", "Q", "P", "N", "M", "L", "K"][index] else ["K", "L", "J", "N", "P", "Q", "R", "T", "U", "W", "X"][index] end;
  
concat(
  l,
  (48 + n1).chr,
  (48 + n2).chr,
  (48 + n3).chr,
  (48 + n4).chr,
  (48 + n5).chr,
  (48 + n6).chr,
  (48 + n7).chr,
  checksum
)