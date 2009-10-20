{-# LANGUAGE DeriveDataTypeable #-}
---------------------------------------------------------
--
-- Module        : Data.Attempt.Helper
-- Copyright     : Michael Snoyman
-- License       : BSD3
--
-- Maintainer    : Michael Snoyman <michael@snoyman.com>
-- Stability     : Unstable
-- Portability   : portable
--
-- Replacements for standard functions to represent failure with an Attempt.
-- Lots of inspiration taken from the "safe" package.
---------------------------------------------------------
module Data.Attempt.Helper
    ( join
    , lookup
    , tail
    , init
    , head
    , last
    , read
    , at
    ) where

import Prelude hiding (lookup, tail, init, head, last, read)
import qualified Prelude
import Data.Attempt
import Control.Monad.Attempt.Class
import Data.Generics
import qualified Control.Exception as E

join :: (FromAttempt m, Monad m) => m (Attempt v) -> m v
join = (>>= fromAttempt)

data KeyNotFound k v = KeyNotFound k [(k, v)]
    deriving Typeable
instance Show k => Show (KeyNotFound k v) where
    show (KeyNotFound key _) = "Could not find requested key: " ++ show key
instance (Typeable k, Typeable v, Show k) => E.Exception (KeyNotFound k v)

lookup :: (Typeable k, Typeable v, Show k, Eq k, MonadAttempt m)
       => k
       -> [(k, v)]
       -> m v
lookup k m = maybe (failure $ KeyNotFound k m) success $ Prelude.lookup k m

data EmptyList = EmptyList
    deriving (Show, Typeable)
instance E.Exception EmptyList

tail :: MonadAttempt m => [a] -> m [a]
tail [] = failure EmptyList
tail (_:rest) = success rest

init :: MonadAttempt m => [a] -> m [a]
init [] = failure EmptyList
init x = success $ Prelude.init x

head :: MonadAttempt m => [a] -> m a
head [] = failure EmptyList
head (x:_) = success x

last :: MonadAttempt m => [a] -> m a
last [] = failure EmptyList
last x = success $ Prelude.last x

newtype CouldNotRead = CouldNotRead String
    deriving (Typeable, Show)
instance E.Exception CouldNotRead

read :: (MonadAttempt m, Read a) => String -> m a
read s = case [x | (x,t) <- reads s, ("","") <- lex t] of
            [x] -> success x
            _ -> failure $ CouldNotRead s

data NegativeIndex = NegativeIndex
    deriving (Typeable, Show)
instance E.Exception NegativeIndex
data OutOfBoundsIndex = OutOfBoundsIndex
    deriving (Typeable, Show)
instance E.Exception OutOfBoundsIndex
at :: MonadAttempt m => [a] -> Int -> m a
at [] _ = failure OutOfBoundsIndex
at (x:_) 0 = success x
at (_:xs) n
    | n < 0 = failure NegativeIndex
    | otherwise = at xs $ n - 1