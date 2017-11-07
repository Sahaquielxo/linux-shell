Very customed script with a lot of defined variables. Rewrite it if you need, I'm too lazy.

### You needs only this script in ```/home/user/.passwords/``` directory and ```.hosts``` file in the same directory.

Strings 8, 9 in my script will rewrite your .hosts file, so remove them!

## Usage:
Run the script. It will: 
+ ul Randomly read "Crime and Punishment" chapters from 1 to 12.
+ ul Choose a randomly character in a very long string.
+ ul Getting next 25 symbols after chosen character.
+ ul Remove all spaces, HTML-tags, rewrite lower-letter to upper (not each letter, just "e", "t", "a").
+ ul Check if the password length greater or equal 15.

After all, you will get N files named by ```password_${hostname}```, for the each of your host.
Theese files will be send to the servers, passwords will be changed by passwd.

At the lane 72, you can make a mail notification to your mail-box.
