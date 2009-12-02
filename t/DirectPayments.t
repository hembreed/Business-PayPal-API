#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

if( ! $ENV{WPP_TEST} || ! -f $ENV{WPP_TEST} ) {
    plan skip_all => 'No WPP_TEST env var set. Please see README to run tests';
}
else {
    plan tests => '9';
}

use Business::PayPal::API qw( DirectPayments CaptureRequest ReauthorizationRequest VoidRequest RefundTransaction );

my @methlist = qw( DirectPayments CaptureRequest ReauthorizationRequest VoidRequest RefundTransaction);
use_ok('Business::PayPal::API', @methlist);

require 't/API.pl';

my %args = do_args();

my ($transale,$tranvoid,$tranbasic,$tranrefund);
my ($ppsale,$ppvoid,$ppbasic,$pprefund,$pprefund1,$ppcap,$ppcap1);
my (%respsale,%resprefund,%resprefund1,%respbasic,%respcap,%respcap1,%respvoid);

#Test Partial Refund on Sale

#$Business::PayPal::API::Debug=1;
$ppsale = new Business::PayPal::API(%args);
%respsale = $ppsale->DoDirectPaymentRequest (
                        PaymentAction    => 'Sale',
                        OrderTotal    => 13.87,
                        TaxTotal       => 0.0,
                        ItemTotal  => 0.0,
                        CreditCardType      => 'Visa',
                        CreditCardNumber        => '4561435600988217',
                        ExpMonth       => '01',
                        ExpYear        => +(localtime)[5]+1901,
                        CVV2       => '123',
                        FirstName      => 'JP',
                        LastName      => 'Morgan',
                        Street1  => '1st Street LaCausa',
                        Street2  => '',
                        CityName      => 'La',
                        StateOrProvince     => 'Ca',
                        PostalCode       => '90210',
                        Country   => 'US',
                        Payer    => 'mall@example.org',
                        CurrencyID  => 'USD',
                        IPAddress        => '10.0.0.1',
                        MerchantSessionID      => '10113301',
                        );
#$Business::PayPal::API::Debug=0;
if(is( $respsale{'Ack'}, 'Success', 'Direct Payment Sale')) {
            $transale = $respsale{'TransactionID'};
#$Business::PayPal::API::Debug=1;
            $pprefund = new Business::PayPal::API(%args);
            %resprefund = $pprefund->RefundTransaction (
                            TransactionID => $transale,
                            RefundType    => 'Partial',
                            Amount        => '3.00',
                            Memo          => 'Partial three dollar refund',
                            );
#$Business::PayPal::API::Debug=0;
            is( $resprefund{'Ack'}, 'Success', 'Partial Refund for sale');
      }

#Test Full Refund on Sale

#$Business::PayPal::API::Debug=1;
$ppsale = new Business::PayPal::API(%args);
%respsale = $ppsale->DoDirectPaymentRequest (
                        PaymentAction    => 'Sale',
                        OrderTotal    => 13.87,
                        TaxTotal       => 0.0,
                        ItemTotal  => 0.0,
                        CreditCardType      => 'Visa',
                        CreditCardNumber        => '4561435600988217',
                        ExpMonth       => '01',
                        ExpYear        => +(localtime)[5]+1901,
                        CVV2       => '123',
                        FirstName      => 'JP',
                        LastName      => 'Morgan',
                        Street1  => '1st Street LaCausa',
                        Street2  => '',
                        CityName      => 'La',
                        StateOrProvince     => 'Ca',
                        PostalCode       => '90210',
                        Country   => 'US',
                        Payer    => 'mall@example.org',
                        CurrencyID  => 'USD',
                        IPAddress        => '10.0.0.1',
                        MerchantSessionID      => '10113301',
                        );
#$Business::PayPal::API::Debug=0;
if(is( $respsale{'Ack'}, 'Success', 'Direct Payment Sale')) {
            $transale = $respsale{'TransactionID'};
#$Business::PayPal::API::Debug=1;
            $pprefund1 = new Business::PayPal::API(%args);
            %resprefund1 = $pprefund1->RefundTransaction (
                            TransactionID => $transale,
                            RefundType    => 'Full',
                            Memo          => 'Full refund',
                            );
#$Business::PayPal::API::Debug=0;
            is( $resprefund1{'Ack'}, 'Success', 'Full Refund for sale');
      }

#Basic Authorization and Capture

%args=do_args();
#$Business::PayPal::API::Debug=0;
$ppbasic = new Business::PayPal::API(%args);
%respbasic = $ppbasic->DoDirectPaymentRequest (
                        PaymentAction    => 'Authorization',
                        OrderTotal    => 13.87,
                        TaxTotal       => 0.0,
                        ItemTotal  => 0.0,
                        CreditCardType      => 'Visa',
                        CreditCardNumber        => '4561435600988217',
                        ExpMonth       => '01',
                        ExpYear        => +(localtime)[5]+1901,
                        CVV2       => '123',
                        FirstName      => 'JP',
                        LastName      => 'Morgan',
                        Street1  => '1st Street LaCausa',
                        Street2  => '',
                        CityName      => 'La',
                        StateOrProvince     => 'Ca',
                        PostalCode       => '90210',
                        Country   => 'US',
                        Payer    => 'mall@example.org',
                        CurrencyID  => 'USD',
                        IPAddress        => '10.0.0.1',
                        MerchantSessionID      => '10113301',
                        );

#$Business::PayPal::API::Debug=0;
if( is( $respbasic{'Ack'}, 'Success', 'Direct Payment Basic Authorization') ) {
    $tranbasic = $respbasic{'TransactionID'};

    #Test Partial Capture
    #$Business::PayPal::API::Debug=1;
    $ppcap = new Business::PayPal::API(%args);

    %respcap = $ppcap->DoCaptureRequest (
					 AuthorizationID => $tranbasic,
					 CompleteType    => 'NotComplete',
					 Amount        => '3.00',
					 Note          => 'Partial Capture',
					);
    #$Business::PayPal::API::Debug=0;
    is( $respcap{'Ack'}, 'Success', 'Partial Capture');

    #Test Full Capture
    #$Business::PayPal::API::Debug=1;
    $ppcap1 = new Business::PayPal::API(%args);
    %respcap1 = $ppcap1->DoCaptureRequest (
					   AuthorizationID => $tranbasic,
					   CompleteType    => 'Complete',
					   Amount          => '6.00',
					  );
    #$Business::PayPal::API::Debug=0;
    is( $respcap1{'Ack'}, 'Success', 'Full Capture');
}
else { skip( "direct payment auth failed", 2 ) }

#Test Void
$ppbasic = new Business::PayPal::API(%args);
%respbasic = $ppbasic->DoDirectPaymentRequest (
                        PaymentAction    => 'Authorization',
                        OrderTotal    => 18.37,
                        TaxTotal       => 0.0,
                        ItemTotal  => 0.0,
                        CreditCardType      => 'Visa',
                        CreditCardNumber        => '4561435600988217',
                        ExpMonth       => '01',
                        ExpYear        => +(localtime)[5]+1901,
                        CVV2       => '123',
                        FirstName      => 'JP',
                        LastName      => 'Morgan',
                        Street1  => '1st Street LaCausa',
                        Street2  => '',
                        CityName      => 'La',
                        StateOrProvince     => 'Ca',
                        PostalCode       => '90210',
                        Country   => 'US',
                        Payer    => 'mall@example.org',
                        CurrencyID  => 'USD',
                        IPAddress        => '10.0.0.1',
                        MerchantSessionID      => '10113301',
                        );

#$Business::PayPal::API::Debug=1;
$ppvoid = new Business::PayPal::API(%args);
%respvoid = $ppvoid->DoVoidRequest ( AuthorizationID => $respbasic{TransactionID},
				     Note            => 'Authorization Void', );
#$Business::PayPal::API::Debug=0;
is( $respvoid{'Ack'}, 'Success', 'Authorization Voided');
