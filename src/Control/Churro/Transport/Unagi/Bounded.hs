{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}

-- | Unagi-Chan Bounded Transport Instance.
-- 
-- This makes use of a KnownNat parameter to specify the size of the buffer.
-- 
module Control.Churro.Transport.Unagi.Bounded where
    
import Control.Churro.Types
import Control.Churro.Prelude

import Control.Concurrent.Chan.Unagi.Bounded
import Data.Void
import Data.Data (Proxy(..))
import GHC.TypeLits (KnownNat, natVal)

-- $setup
-- 
-- Test Setup
-- 
-- >>> :set -XDataKinds
-- >>> import Control.Churro

data UnagiBounded n a

instance KnownNat n => Transport (UnagiBounded n) where
    data In  (UnagiBounded n) a = ChanIn  (InChan  a)
    data Out (UnagiBounded n) a = ChanOut (OutChan a)
    yank (ChanOut c) = readChan  c
    yeet (ChanIn  c) = writeChan c
    flex = do 
        (i, o) <- newChan (fromIntegral (natVal (Proxy :: Proxy n)))
        return (ChanIn i, ChanOut o)

type ChurroUnagiBounded n = Churro (UnagiBounded n)

-- | Convenience function for running a Churro with a Bounded Unagi-Chan Transport.
-- 
runWaitUnagi :: KnownNat n => ChurroUnagiBounded n Void Void -> IO ()
runWaitUnagi = runWait

-- | Convenience function for running a Churro into a List with a Bounded Unagi-Chan Transport.
-- 
-- >>> runWaitListUnagi @10 $ sourceList [1,2,3] >>> arr succ
-- [2,3,4]
runWaitListUnagi :: KnownNat n => ChurroUnagiBounded n Void o -> IO [o]
runWaitListUnagi = runWaitList