{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}

module Backend where

import Backend.Entrypoint (start)
import Common.Route
import Control.Lens
import Control.Monad.IO.Class (liftIO)
import Data.Aeson
import qualified Data.ByteString.Lazy as BSL
import Data.Dependent.Sum (DSum (..))
import Obelisk.Backend
import Snap

backend :: Backend BackendRoute FrontendRoute
backend = Backend
  { _backend_run = \serve -> do
      getLinks <- liftIO start
      serve $ \case
        BackendRoute_Missing :=> Identity () ->
          writeLBS "404"
        BackendRoute_GetData :=> Identity () -> do
          links <- liftIO getLinks
          writeBS $ BSL.toStrict $ encode links,
    _backend_routeEncoder = fullRouteEncoder
  }
