{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

{-# OPTIONS_GHC -fno-warn-deprecations #-}

module Cardano.AddressSpec
    ( spec
    ) where

import Prelude

import Cardano.Address
    ( Address
    , DelegationAddress (..)
    , HasNetworkDiscriminant (..)
    , PaymentAddress (..)
    , base58
    , bech32
    , fromBase58
    , fromBech32
    )
import Cardano.Address.Derivation
    ( Depth (..), XPub )
import Cardano.Address.Style.Byron
    ( Byron )
import Cardano.Address.Style.Icarus
    ( Icarus )
import Cardano.Address.Style.Jormungandr
    ( Jormungandr )
import Data.Function
    ( (&) )
import Data.Text
    ( Text )
import Test.Arbitrary
    ()
import Test.Hspec
    ( Spec, describe )
import Test.Hspec.QuickCheck
    ( prop )
import Test.QuickCheck
    ( Property, counterexample, label )

import qualified Data.Text as T

spec :: Spec
spec = describe "Text Encoding Roundtrips" $ do
    prop "base58 . fromBase58 - Byron" $
        prop_roundtripTextEncoding @Byron base58 fromBase58

    prop "base58 . fromBase58 - Icarus" $
        prop_roundtripTextEncoding @Icarus base58 fromBase58

    prop "bech32 . fromBech32 - Byron" $
        prop_roundtripTextEncoding @Byron bech32 fromBech32

    prop "bech32 . fromBech32 - Icarus" $
        prop_roundtripTextEncoding @Icarus bech32 fromBech32

    prop "bech32 . fromBech32 - Jormungandr - payment address" $
        prop_roundtripTextEncoding @Jormungandr bech32 fromBech32

    prop "bech32 . fromBech32 - Jormungandr - delegation address" $
        prop_roundtripTextEncodingDelegation @Jormungandr bech32 fromBech32

-- Ensure that any address public key can be encoded to an address and that the
-- address can be encoded and decoded without issues.
prop_roundtripTextEncoding
    :: forall k. (PaymentAddress k)
    => (Address -> Text)
        -- ^ encode to 'Text'
    -> (Text -> Maybe Address)
        -- ^ decode from 'Text'
    -> k 'PaymentK XPub
        -- ^ An arbitrary public key
    -> NetworkDiscriminant k
        -- ^ An arbitrary network discriminant
    -> Property
prop_roundtripTextEncoding encode decode addXPub discrimination =
    (result == pure address)
        & counterexample (unlines
            [ "Address " <> T.unpack (encode address)
            , "↳       " <> maybe "ø" (T.unpack . encode) result
            ])
        & label (show $ addressDiscrimination @k discrimination)
  where
    address = paymentAddress discrimination addXPub
    result  = decode (encode address)

prop_roundtripTextEncodingDelegation
    :: forall k. (DelegationAddress k)
    => (Address -> Text)
        -- ^ encode to 'Text'
    -> (Text -> Maybe Address)
        -- ^ decode from 'Text'
    -> k 'PaymentK XPub
        -- ^ An arbitrary address public key
    -> k 'DelegationK XPub
        -- ^ An arbitrary delegation public key
    -> NetworkDiscriminant k
        -- ^ An arbitrary network discriminant
    -> Property
prop_roundtripTextEncodingDelegation encode decode addXPub delegXPub discrimination =
    (result == pure address)
        & counterexample (unlines
            [ "Address " <> T.unpack (encode address)
            , "↳       " <> maybe "ø" (T.unpack . encode) result
            ])
        & label (show $ addressDiscrimination @k discrimination)
  where
    address = delegationAddress discrimination addXPub delegXPub
    result  = decode (encode address)
