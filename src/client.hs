import Control.Concurrent
import Network
import System.Environment
import System.IO
import System.Exit

main :: IO ()
main = do
	--connect to the hostand port
    args <- getArgs
    if null args then putStrLn "Invalid/Incomplete Arguments"
    				  >> exitFailure
    else putStrLn "Running"
    let [host,port] = args
    serveConn <- connectTo host $ PortNumber $ toEnum $ read port
    --set buffering for speed
    hSetBuffering stdout LineBuffering
    hSetBuffering serveConn LineBuffering
    --put a message in the connection data queue
    _ <- sendEcho serveConn "Hello World"
    --receive anything that comes back
    _ <- forkIO $ hGetContents serveConn >>= putStr
    getContents >>= hPutStr serveConn

sendEcho :: Handle -> String -> IO ThreadId
sendEcho conn msgStr = forkIO $ do 
	hPutStrLn conn ("echo " ++ msgStr)
	self <- myThreadId
	--kills self for RAII
	killThread self

--looped derivative
ddosEcho :: Handle -> String -> IO ThreadId
ddosEcho conn msgStr = forkIO $ do 
	hPutStrLn conn ("echo " ++ msgStr)
	self <- myThreadId
	_ <- ddosEcho conn msgStr
	--kills self for RAII
	killThread self

checkBuffer :: Handle -> IO ThreadId
checkBuffer conn = forkIO $ hGetContents conn >>= putStr

