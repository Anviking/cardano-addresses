{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE UndecidableInstances #-}

{-# OPTIONS_GHC -fno-warn-orphans #-}

-- |
-- Copyright: © 2018-2021 IOHK
-- License: Apache-2.0
--
-- Utility functions for internal use of the library.

module Cardano.Address.Internal
    ( orElse
    , WithErrorMessage (..)
    , DeserialiseFailure (..)
    ) where

import Prelude

import Codec.CBOR.Read
    ( DeserialiseFailure (..) )
import Control.Exception
    ( Exception (..) )
import Data.Aeson
    ( GToJSON
    , Options (..)
    , SumEncoding (..)
    , ToJSON (..)
    , Value
    , Zero
    , defaultOptions
    , genericToJSON
    , object
    , toJSON
    , (.=)
    )
import GHC.Generics
    ( Generic, Rep )

orElse :: Either e a -> Either e a -> Either e a
orElse (Right a) _ = Right a
orElse (Left _) ea = ea

errToJSON :: (Exception e, Generic e, GToJSON Zero (Rep e)) => e -> Value
errToJSON err = object
    [ "error" .= genericToJSON opts err
    , "message" .= toJSON (displayException err)
    ]
  where
    opts = defaultOptions { sumEncoding = errorCodes }
    errorCodes = TaggedObject "code" "details"

newtype WithErrorMessage e = WithErrorMessage { withErrorMessage :: e }

instance (Exception e, Generic e, GToJSON Zero (Rep e)) => ToJSON (WithErrorMessage e) where
    toJSON = errToJSON . withErrorMessage

instance ToJSON DeserialiseFailure where
    toJSON = toJSON . displayException
