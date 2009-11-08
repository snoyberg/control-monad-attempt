{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE FlexibleContexts #-}
---------------------------------------------------------
--
-- Module        : Control.Monad.Attempt.Class
-- Copyright     : Michael Snoyman
-- License       : BSD3
--
-- Maintainer    : Michael Snoyman <michael@snoyman.com>
-- Stability     : Unstable
-- Portability   : portable
--
---------------------------------------------------------

-- | Defines a type class for any monads which may report failure using
-- extensible exceptions.
module Control.Monad.Attempt.Class
    ( StringException (..)
    , failureString
    , module Control.Monad.Failure
    ) where

import Control.Exception
import Data.Generics
import Control.Monad.Failure

-- | Call 'failure' by wrapping the argument in a 'StringException'.
failureString :: MonadFailure StringException m => String -> m a
failureString = failure . StringException

-- | A simple exception which simply contains a string. Note that the 'Show'
-- instance simply returns the contained string.
newtype StringException = StringException String
    deriving Typeable
instance Show StringException where
    show (StringException s) = s
instance Exception StringException
