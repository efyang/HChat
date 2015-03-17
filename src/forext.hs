import System.Process

main :: IO()
main = do 
	ipaddr <- readProcess "./getip" [] [] 
	print (splitAt (length ipaddr - 1) ipaddr)
		  
 
		  
