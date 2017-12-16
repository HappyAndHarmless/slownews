{-# LANGUAGE OverloadedStrings #-}

module SlowNews.Reddit where

import           Control.Lens
import           Data.Aeson                    (FromJSON (..),
                                                withObject, (.:))
import qualified Network.Wreq                  as WQ
import SlowNews.Link (Link(..))

data Body =
  Body { bodyChildren :: [Link] }
  deriving (Show, Eq)

instance FromJSON Body where
  parseJSON = withObject "Body" $ \v -> do
    d <- v .: "data"
    Body <$> d .: "children"

instance FromJSON Link where
  parseJSON = withObject "Link" $ \v -> do
    d <- v .: "data"
    Link <$> d .: "title"
         <*> d .: "url"
         <*> d .: "permalink"
         <*> d .: "created_utc"
         <*> d .: "subreddit_name_prefixed"

fetchSubreddit :: String -> Maybe Int -> IO [Link]
fetchSubreddit subreddit countMaybe = do
  r <- WQ.asJSON =<< WQ.get (url countMaybe) :: IO (WQ.Response Body)
  return $ r ^. WQ.responseBody & bodyChildren
  where
    url Nothing =
      "https://www.reddit.com/r/" ++ subreddit ++ "/top/.json?sort=top&t=week"
    url (Just count) =
      url Nothing ++ "&limit=" ++ show count