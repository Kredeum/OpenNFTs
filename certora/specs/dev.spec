import "buy.spec";

use rule buyOnlyBalBuyerDecrease;
use rule buyOnlyBalSellerOrTreasuryOrReceiverIncrease;
use rule buyBuyerBecomesOwner;
use rule buySumOfBalsUnChanged;