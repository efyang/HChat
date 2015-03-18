import Control.Concurrent
import Network
import System.Environment
import System.IO
import System.Exit
import Data.List(isPrefixOf)

mkconn :: IO Handle
mkconn = do 
    --connect to the hostand port
    args <- getArgs
    if length args /= 2 then putStrLn "\nError: Invalid/Incomplete Arguments"
                      >> exitFailure
    else putStrLn "Client is starting up.\n"
    let [host,port] = args
    serveConn <- connectTo host $ PortNumber $ toEnum $ read port
    --set buffering for speed
    hSetBuffering stdout LineBuffering
    hSetBuffering serveConn LineBuffering
    return serveConn

main :: IO ()
main = do
    serveConn <- mkconn
    --put a message in the connection data queue
    _ <- forkIO $ sendEcho serveConn
    --receive anything that comes back
    checkBuffer serveConn 
    putStrLn "All Jobs Started"
    

sendEcho :: Handle -> IO()
sendEcho conn = do
    putStrLn "Input Message: "
    userinput <- getLine
    echoStr conn userinput 
    sendEcho conn

echoStr :: Handle -> String -> IO ()
echoStr conn str = hPutStrLn conn ("echo " ++ str)

checkBuffer :: Handle -> IO()
checkBuffer conn = do
    buffer <- hGetContents conn 
    msgProcessor buffer conn
    checkBuffer conn

msgProcessor :: String -> Handle -> IO()
msgProcessor msgStr conn | "msg" `isPrefixOf` msgStr = putStrLn ("Message from server: " ++ msgStr)
                         | otherwise = return ()