import Network (listenOn, withSocketsDo, accept, PortID(..), Socket)
import System.Environment (getArgs)
import System.IO (hSetBuffering, hGetLine, hPutStrLn, hPrint,BufferMode(..), Handle)
import Control.Concurrent (forkIO)
import System.Process(readProcess)

getip :: IO String
getip = do
    rawip <- readProcess "curl" ["http://icanhazip.com"] [] 
    let ipaddr = fst (splitAt (length rawip - 1) rawip)
    return ipaddr

main :: IO ()
main = withSocketsDo $ do
    args <- getArgs
    myip <- getip
    let checkedArgs = defaultport args
    let port = fromIntegral (read $ head checkedArgs :: Int)
    sock <- listenOn $ PortNumber port
    putStrLn $ "Listening on Host: " ++ myip ++ " Port:" ++ head checkedArgs
    sockHandler sock

defaultport :: [String] -> [String]
defaultport ports | null ports = ["5000"]
				  | otherwise = ports

sockHandler :: Socket -> IO ()
sockHandler sock = do
    (handle, host, port) <- accept sock
    hSetBuffering handle NoBuffering
    putStrLn ("User at Host: " ++ show host ++ " Port: " ++ show port ++ " connected.")
    _ <- forkIO $ commandProcessor handle
    sockHandler sock

commandProcessor :: Handle -> IO ()
commandProcessor handle = do
    line <- hGetLine handle
    let cmd = words line
    case head cmd of
        ("echo") -> echoCommand handle cmd
        ("add") -> addCommand handle cmd
        _ -> hPutStrLn handle "Unknown command"
    commandProcessor handle

echoCommand :: Handle -> [String] -> IO ()
echoCommand handle cmd = hPutStrLn handle (unwords $ tail cmd)

addCommand :: Handle -> [String] -> IO ()
addCommand handle cmd = hPrint handle ((read (cmd !! 1) :: Int) + (read (cmd !! 2) :: Int))