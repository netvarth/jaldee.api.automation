***Settings***
Test Teardown    Delete All Sessions
Suite Teardown    resetsystem_time
Force Tags        Invoice
Library           Collections
Library           String
Library           json
Library         /ebs/TDD/db.py
Library         FakerLibrary
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Resource        /ebs/TDD/SuperAdminKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py

*** Test Cases ***

JD-TC-Invoice-1
    [Documentation]   invoice after license upgrade
    ${resp}=  get_iscorp_subdomains  0
    Set Test Variable  ${d1}  ${resp[0]['domain']}
    Set Test Variable  ${sd1}  ${resp[0]['subdomains']}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph}=  Evaluate  ${PUSERNAME7}+72010
    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    ${index}=  Evaluate  ${liclen}/2
    Set Test Variable  ${pkgId}  ${licresp.json()[${index}]['pkgId']}
    Set Test Variable  ${lprice1}  ${licresp.json()[${index}]['price']}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${ph}   ${pkgId}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${ph}  0
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${ph}${\n}

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${randomval1}    FakerLibrary.Numerify  %%%%%%%%
    ${randomval2}    FakerLibrary.Numerify  %%%%%%%%
    ${ph1}=  Evaluate  ${ph}+${randomval1}
    ${ph2}=  Evaluate  ${ph}+${randomval2}
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${ph}.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule    ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep   10s
    ${pid}=  get_acc_id  ${ph}
    # ${resp}=  Get Invoices  NotPaid
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${licuuid}   ${resp.json()[0]['ynwUuid']}
    # ${len}=  Get Length  ${resp.json()}
    # Should Be Equal As Integers  ${len}  1
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  bill_cycle
    # Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${DAY1}  periodFrom=${DAY1}  periodTo=${DAY2}  amount=${resp.json()[0]['licensePkgDetails']['amount']}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=True  balance=0.0
    # Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${pkgId}
    # Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${lprice1}

    change_system_date  5
    ${cday}=  db.get_date_by_timezone  ${tz}
    ${resp}=   Encrypted Provider Login  ${ph}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get upgradable license 
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${licId2}  ${resp.json()[0]['pkgId']}
    Set Test Variable  ${lprice2}  ${resp.json()[0]['price']}
    ${resp}=  Change License Package  ${licId2}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Invoices  NotPaid
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    ${sil}=  get_days  ${DAY1}  ${DAY2}
    ${gol}=  get_days  ${cday}  ${DAY2}
    ${amount}=  Evaluate  float(${lprice1})/${sil}*5+float(${lprice2})/${sil}*${gol}
    ${amount}=  Convert To Number  ${amount}  0
    ${l2price}=  Evaluate  ${amount}-${lprice1}
    Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${cday}  periodFrom=${cday}  periodTo=${DAY2}  amount=${l2price}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=False  #balance=${lprice1}
    ...   balance=0.0
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${licId2}
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${l2price}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['accountId']}  ${pid}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['ynwUuid']}  ${licuuid}


JD-TC-Invoice-2
    [Documentation]   addon in the middle of bill cycle
    ${resp}=  get_iscorp_subdomains  0
    Set Test Variable  ${d1}  ${resp[0]['domain']}
    Set Test Variable  ${sd1}  ${resp[0]['subdomains']}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph}=  Evaluate  ${PUSERNAME7}+72011
    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    ${index}=  Evaluate  ${liclen}/2
    Set Test Variable  ${pkgId}  ${licresp.json()[${index}]['pkgId']}
    Set Test Variable  ${lprice1}  ${licresp.json()[${index}]['price']}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${ph}   ${pkgId}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${ph}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${ph}${\n}
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${ph}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${randomval1}    FakerLibrary.Numerify  %%%%%%%%
    ${randomval2}    FakerLibrary.Numerify  %%%%%%%%
    ${ph1}=  Evaluate  ${ph}+${randomval1}
    ${ph2}=  Evaluate  ${ph}+${randomval2}
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${ph}.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule    ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep   10s

    # ${resp}=  Get Invoices  NotPaid
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${licuuid}   ${resp.json()[0]['ynwUuid']}
    # ${len}=  Get Length  ${resp.json()}
    # Should Be Equal As Integers  ${len}  1
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  bill_cycle
    # Set Test Variable  ${DAY2}
    # Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${DAY1}  periodFrom=${DAY1}  periodTo=${DAY2}  amount=${resp.json()[0]['licensePkgDetails']['amount']}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=True  balance=0.0
    # Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${pkgId}
    # Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${lprice1}

    ${daysR}=  get_days  ${DAY1}  ${DAY2}
    ${mid}=  Evaluate  ${daysR}/2
    change_system_date  ${mid}
    ${cdate}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Addons Metadata
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable  ${aId}  ${resp.json()[1]['addons'][1]['addonId']}
    Set Test Variable  ${aprice}  ${resp.json()[1]['addons'][1]['price']}
    ${resp}=  Add addon  ${aId} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Invoices  NotPaid
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    ${sil}=  get_days  ${DAY1}  ${DAY2}
    ${gol}=  get_days  ${cdate}  ${DAY2}
    ${adprice}=  Evaluate  float(${aprice})/${sil}*${gol}
    ${adprice}=  Convert To Number  ${adprice}  2
    ${amount}=  Evaluate  ${adprice}+${lprice1}

    Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${cdate}  periodFrom=${cdate}  periodTo=${DAY2}  amount=${adprice}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=False  #balance=${lprice1}
    ...   balance=0.0
    Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${aId}
    Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['amount']}  ${adprice}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['accountId']}  ${pid}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['ynwUuid']}  ${licuuid}


JD-TC-Invoice-3
    [Documentation]   Change subscription to Annual
    ${resp}=  get_iscorp_subdomains  0
    Set Test Variable  ${d1}  ${resp[0]['domain']}
    Set Test Variable  ${sd1}  ${resp[0]['subdomains']}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph}=  Evaluate  ${PUSERNAME7}+72012
    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    ${index}=  Evaluate  ${liclen}/2
    Set Test Variable  ${pkgId}  ${licresp.json()[${index}]['pkgId']}
    Set Test Variable  ${lprice1}  ${licresp.json()[${index}]['price']}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${ph}   ${pkgId}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${ph}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${ph}${\n}
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${randomval1}    FakerLibrary.Numerify  %%%%%%%%
    ${randomval2}    FakerLibrary.Numerify  %%%%%%%%
    ${ph1}=  Evaluate  ${ph}+${randomval1}
    ${ph2}=  Evaluate  ${ph}+${randomval2}
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${ph}.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule    ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${ph}
    # ${resp}=  Get Invoices  NotPaid
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${licuuid}   ${resp.json()[0]['ynwUuid']}
    # ${len}=  Get Length  ${resp.json()}
    # Should Be Equal As Integers  ${len}  1
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  bill_cycle
    # Set Test Variable  ${DAY2}
    # Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${DAY1}  periodFrom=${DAY1}  periodTo=${DAY2}  amount=${resp.json()[0]['licensePkgDetails']['amount']}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=True  balance=0.0
    # Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${pkgId}
    # Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${lprice1}

    ${daysR}=  get_days  ${DAY1}  ${DAY2}
    ${mid}=  Evaluate  ${daysR}/2
    change_system_date  ${mid}
    ${cdate}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Change Bill Cycle  ${billCycle[0]} 
    Should Be Equal As Strings    ${resp.status_code}   200
    db.change_date_with_tz  ${tz}   ${DAY2} 
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ProviderKeywords.Generate Invoice
    Should Be Equal As Strings    ${resp.status_code}   200
    ${eday}=  bill_cycle_annual
    ${resp}=  Get Invoices  NotPaid
    Log  ${resp.json()}  
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${discPerc}  ${resp.json()[0]['annualDiscPct']}
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1

    ${annualPrice}=  Evaluate  float(${lprice1})*12
    ${anualDisc}=  Evaluate  float(${annualPrice}*${discPerc}/100)
    ${discprice}=  Evaluate  ${annualPrice}-${anualDisc}
    ${amount}=  Evaluate  ${annualPrice}-${anualDisc}+${lprice1}

    Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${DAY2}  periodFrom=${DAY2}  periodTo=${eday}  amount=${discprice}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=True  #balance=${lprice1}  annualDiscAmount=${anualDisc}
    ...   balance=0.0  annualDiscAmount=${anualDisc}
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${pkgId}
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${annualPrice}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['accountId']}  ${pid}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['ynwUuid']}  ${licuuid}


JD-TC-Invoice-4
    [Documentation]  Apply SC discount

    ${resp}=  SuperAdmin Login  ${SUSERNAME}   ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp_config}=  Get SC Configuration
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp_accnt_config}=  Get SCAccount Configuration
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${providerDiscDuration}   ${resp_config.json()['defaultProJaldeeDiscDuration']}
    Set Test Variable  ${providerDiscFromJaldee}  ${resp_config.json()['defaultProDiscFromJaldee']}
    Set Test Variable  ${bonusPeriod}  ${resp_accnt_config.json()['scBonusPeriodDetails'][0]['value']}
    Set Test Variable  ${scType}  ${resp_accnt_config.json()['scTypeDetails'][0]['value']}
    Set Test Variable  ${commissionPct}  ${resp_config.json()['defaultComModelPct']}
    Set Test Variable  ${commissionDuration}  ${resp_config.json()['comModelMaxTillMonth']}
    Set Test Variable  ${id}   ${resp_config.json()['bonusRates'][0]['id']}
    Set Test Variable  ${targetCount}   ${resp_config.json()['bonusRates'][0]['targetCount']}
    Set Test Variable  ${rate}   ${resp_config.json()['bonusRates'][0]['rate']}
    ${radiusCoverage}  Random Int  min=0   max=10
    ${scId}=  db.Generate_ScId
    ${scName}  FakerLibrary.name
    ${contactFirstName}   FakerLibrary.first_name
    ${contactLastName}   FakerLibrary.last_name
    ${address}   db.get_address
    ${city}  db.get_place
    ${metro}   db.get_place
    ${state}   db.get_place
    ${privateNote}  FakerLibrary.name
    ${pincodesCoverage}  FakerLibrary.postcode
    ${primaryPhoneNo}=  Evaluate  ${PUSERNAME19}+5001 
    ${altPhoneNo1}=   Evaluate  ${PUSERNAME19}+5002
    ${altPhoneNo2}=  Evaluate  ${PUSERNAME19}+5003
    ${latitude}  get_latitude
    ${longitude}  get_longitude
    ${providerDiscFromJaldee}=  Convert To Number  ${providerDiscFromJaldee}  0 
    ${commissionPct}=  Convert To Number  ${commissionPct}  0
    clear_ScTable  ${primaryPhoneNo} 
    Set Test Variable  ${PrimaryEmail}    ${primaryPhoneNo}.${test_mail}
    Set Test Variable  ${altEmail2}   ${altPhoneNo2}.${test_mail}
    Set Test Variable  ${altEmail1}   ${altPhoneNo1}.${test_mail}
    
    ${resp}=  Create SA SalesChannel  ${scId}  ${providerDiscFromJaldee}  ${providerDiscDuration}  ${scName}   ${contactFirstName}  ${contactLastName}  ${address}   ${city}  ${metro}   ${state}   ${latitude}   ${longitude}   ${radiusCoverage}   ${pincodesCoverage}   ${scType}   ${primaryPhoneNo}   ${altPhoneNo1}   ${altPhoneNo2}   ${commissionDuration}   ${commissionPct}   ${PrimaryEmail}   ${altEmail1}   ${altEmail2}   ${bonusPeriod}   ${id}  ${targetCount}   ${rate}  ${privateNote}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${respo}=  SuperAdminKeywords.Get SalesChannel By Id  ${ScId}
    ${len}=  Get Length  ${resp_config.json()['scDiscCodes']}
    ${len}=  Evaluate  ${len}-1
    ${index}=  Random Int  min=0   max=${len}
    ${month}=  Random Int  min=2   max=12
    Set Test Variable  ${scCode}  ${scId}-${resp_config.json()['scDiscCodes'][${index}]['code']}${month}-0-0
    ${resp}=  get_iscorp_subdomains  0
    Set Test Variable  ${d1}  ${resp[0]['domain']}
    Set Test Variable  ${sd1}  ${resp[0]['subdomains']}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph}=  Evaluate  ${PUSERNAME7}+72013
    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    ${licindex}=  Evaluate  ${liclen}/2
    Set Test Variable  ${pkgId}  ${licresp.json()[${licindex}]['pkgId']}
    Set Test Variable  ${lprice1}  ${licresp.json()[${licindex}]['price']}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${ph}   ${pkgId}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${ph}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${ph}${\n}
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Add SalesChannel  ${scCode}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${randomval1}    FakerLibrary.Numerify  %%%%%%%%
    ${randomval2}    FakerLibrary.Numerify  %%%%%%%%
    ${ph1}=  Evaluate  ${ph}+${randomval1}
    ${ph2}=  Evaluate  ${ph}+${randomval2}
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${ph}.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule    ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${ph}
    # ${resp}=  Get Invoices  NotPaid
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${licuuid}   ${resp.json()[0]['ynwUuid']}
    # ${len}=  Get Length  ${resp.json()}
    # Should Be Equal As Integers  ${len}  1
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  bill_cycle
    Set Test Variable  ${DAY2}
    # Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${DAY1}  periodFrom=${DAY1}  periodTo=${DAY2}  amount=${resp.json()[0]['licensePkgDetails']['amount']}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=True  balance=0.0
    # Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${pkgId}
    # Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${lprice1}

    db.change_date_with_tz  ${tz}   ${DAY2} 
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ProviderKeywords.Generate Invoice
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Invoices  NotPaid
    Should Be Equal As Strings    ${resp.status_code}    200
    ${eday}=  bill_cycle
    Set Test Variable  ${scdiscpct}  ${resp_config.json()['scDiscCodes'][${index}]['value']}
    ${scdiscpct}=  Convert To Number  ${scdiscpct}  1
    ${discJD}=  Evaluate  float(${lprice1}*${providerDiscFromJaldee}/100)
    ${discJD}=  Convert To Number  ${discJD}  2
    ${scdiscappamnt}=  Evaluate  ${lprice1}-${discJD}
    ${discSC}=  Evaluate  float(${scdiscappamnt}*${scdiscpct}/100)
    ${discSC}=  Convert To Number  ${discSC}  2
    ${discprice}=  Evaluate  ${lprice1}-${discSC}-${discJD}
    ${amount}=  Evaluate  ${lprice1}-${discSC}-${discJD}+${lprice1}

    Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${DAY2}  periodFrom=${DAY2}  periodTo=${eday}  amount=${discprice}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=True  #balance=${lprice1}  
    ...   balance=0.0  providerDiscAmtByJaldee=${discJD}  providerDiscAmtBySc=${discSC}   providerDiscPctByJaldee=${providerDiscFromJaldee}  providerDiscPctBySc=${scdiscpct}  #jaldeeDiscAppliedAmt=${lprice1}  
    ...   jaldeeDiscAppliedAmt=0.0  scDiscAppliedAmt=${scdiscappamnt}  scDiscAppliedMonths=1  #jaldeeDiscAppliedMonths=1
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${pkgId}
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${lprice1}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['accountId']}  ${pid}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['ynwUuid']}  ${licuuid}


JD-TC-Invoice-5
    [Documentation]  Apply SC discount on yearly subscription

    ${resp}=  SuperAdmin Login  ${SUSERNAME}   ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp_config}=  Get SC Configuration
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp_accnt_config}=  Get SCAccount Configuration
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${providerDiscDuration}   ${resp_config.json()['defaultProJaldeeDiscDuration']}
    Set Test Variable  ${providerDiscFromJaldee}  ${resp_config.json()['defaultProDiscFromJaldee']}
    Set Test Variable  ${bonusPeriod}  ${resp_accnt_config.json()['scBonusPeriodDetails'][0]['value']}
    Set Test Variable  ${scType}  ${resp_accnt_config.json()['scTypeDetails'][0]['value']}
    Set Test Variable  ${commissionPct}  ${resp_config.json()['defaultComModelPct']}
    Set Test Variable  ${commissionDuration}  ${resp_config.json()['comModelMaxTillMonth']}
    Set Test Variable  ${id}   ${resp_config.json()['bonusRates'][0]['id']}
    Set Test Variable  ${targetCount}   ${resp_config.json()['bonusRates'][0]['targetCount']}
    Set Test Variable  ${rate}   ${resp_config.json()['bonusRates'][0]['rate']}
    ${radiusCoverage}  Random Int  min=0   max=10
    ${scId}=  db.Generate_ScId
    ${scName}  FakerLibrary.name
    ${contactFirstName}   FakerLibrary.first_name
    ${contactLastName}   FakerLibrary.last_name
    ${address}   db.get_address
    ${city}  db.get_place
    ${metro}   db.get_place
    ${state}   db.get_place
    ${privateNote}  FakerLibrary.name
    ${pincodesCoverage}  FakerLibrary.postcode
    ${primaryPhoneNo}=  Evaluate  ${PUSERNAME19}+5001 
    ${altPhoneNo1}=   Evaluate  ${PUSERNAME19}+5002
    ${altPhoneNo2}=  Evaluate  ${PUSERNAME19}+5003
    ${latitude}  get_latitude
    ${longitude}  get_longitude
    ${providerDiscFromJaldee}=  Convert To Number  ${providerDiscFromJaldee}  0 
    ${commissionPct}=  Convert To Number  ${commissionPct}  0
    clear_ScTable  ${primaryPhoneNo} 
    Set Test Variable  ${PrimaryEmail}    ${primaryPhoneNo}.${test_mail}
    Set Test Variable  ${altEmail2}   ${altPhoneNo2}.${test_mail}
    Set Test Variable  ${altEmail1}   ${altPhoneNo1}.${test_mail}
    
    ${resp}=  Create SA SalesChannel  ${scId}  ${providerDiscFromJaldee}  ${providerDiscDuration}  ${scName}   ${contactFirstName}  ${contactLastName}  ${address}   ${city}  ${metro}   ${state}   ${latitude}   ${longitude}   ${radiusCoverage}   ${pincodesCoverage}   ${scType}   ${primaryPhoneNo}   ${altPhoneNo1}   ${altPhoneNo2}   ${commissionDuration}   ${commissionPct}   ${PrimaryEmail}   ${altEmail1}   ${altEmail2}   ${bonusPeriod}   ${id}  ${targetCount}   ${rate}  ${privateNote}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${respo}=  SuperAdminKeywords.Get SalesChannel By Id  ${ScId}
    ${len}=  Get Length  ${resp_config.json()['scDiscCodes']}
    ${len}=  Evaluate  ${len}-1
    ${index}=  Random Int  min=0   max=${len}
    ${month}=  Random Int  min=2   max=10
    Set Test Variable  ${scCode}  ${scId}-${resp_config.json()['scDiscCodes'][${index}]['code']}${month}-0-0
    ${resp}=  get_iscorp_subdomains  0
    Set Test Variable  ${d1}  ${resp[0]['domain']}
    Set Test Variable  ${sd1}  ${resp[0]['subdomains']}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph}=  Evaluate  ${PUSERNAME7}+72014
    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    ${licindex}=  Evaluate  ${liclen}/2
    Set Test Variable  ${pkgId}  ${licresp.json()[${licindex}]['pkgId']}
    Set Test Variable  ${lprice1}  ${licresp.json()[${licindex}]['price']}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${ph}   ${pkgId}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${ph}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${ph}${\n}
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Change Bill Cycle  ${billCycle[0]} 
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Add SalesChannel  ${scCode}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${randomval1}    FakerLibrary.Numerify  %%%%%%%%
    ${randomval2}    FakerLibrary.Numerify  %%%%%%%%
    ${ph1}=  Evaluate  ${ph}+${randomval1}
    ${ph2}=  Evaluate  ${ph}+${randomval2}
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${ph}.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule    ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${pid}=  get_acc_id  ${ph}
    # ${resp}=  Get Invoices  NotPaid
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${licuuid}   ${resp.json()[0]['ynwUuid']}
    # ${len}=  Get Length  ${resp.json()}
    # Should Be Equal As Integers  ${len}  1
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  bill_cycle
    # Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${DAY1}  periodFrom=${DAY1}  periodTo=${DAY2}  amount=${resp.json()[0]['licensePkgDetails']['amount']}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=True  balance=0.0
    # Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${pkgId}
    # Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${lprice1}
    db.change_date_with_tz  ${tz}   ${DAY2} 
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ProviderKeywords.Generate Invoice
    Should Be Equal As Strings    ${resp.status_code}   200
    ${eday}=  bill_cycle_annual
    ${resp}=  Get Invoices  NotPaid
    Log  ${resp.json()}  
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${discPerc}  ${resp.json()[0]['annualDiscPct']}
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    Set Test Variable  ${scdiscpct}  ${resp_config.json()['scDiscCodes'][${index}]['value']}
    ${scdiscpct}=  Convert To Number  ${scdiscpct}  1
    ${annualPrice}=  Evaluate  float(${lprice1})*12
    ${anualDisc}=  Evaluate  float(${annualPrice}*${discPerc}/100)
    ${annualPriceAfterdisc}=  Evaluate  ${annualPrice}-${anualDisc}
    ${permonth}=  Evaluate  ${annualPriceAfterdisc}/12
    ${permonth}=  Convert To Number  ${permonth}  2
    ${scmonth}=  Evaluate  ${month}-1
    ${jdmonth}=  Evaluate  ${providerDiscDuration}-1
    ${jaldeeDiscAppliedAmt}=  Evaluate  ${permonth}*${jdmonth}
    ${providerDiscAmtByJaldee}=  Evaluate  ${jaldeeDiscAppliedAmt}*${providerDiscFromJaldee}/100
    ${providerDiscAmtByJaldee}=  Convert To Number  ${providerDiscAmtByJaldee}  2
    ${amountAfterJDDisc}=  Evaluate  ${annualPriceAfterdisc}-${providerDiscAmtByJaldee}
    ${permonthAfterJDdisc}=  Evaluate  ${amountAfterJDDisc}/12
    ${scDiscAppliedAmt}=  Evaluate  ${permonthAfterJDdisc}*${scmonth}
    ${providerDiscAmtBySc}=  Evaluate  ${scDiscAppliedAmt}*${scdiscpct}/100
    ${scDiscAppliedAmt}=  Convert To Number  ${scDiscAppliedAmt}  2
    ${providerDiscAmtBySc}=  Convert To Number  ${providerDiscAmtBySc}  2
    ${discprice}=  Evaluate  ${amountAfterJDDisc}- ${providerDiscAmtBySc}
    ${amount}=  Evaluate  ${amountAfterJDDisc}- ${providerDiscAmtBySc}+${lprice1}
    

    Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${DAY2}  periodFrom=${DAY2}  periodTo=${eday}  amount=${discprice}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=True  #balance=${lprice1}  
    ...   balance=0.0   providerDiscAmtByJaldee=${providerDiscAmtByJaldee}  providerDiscAmtBySc=${providerDiscAmtBySc}   providerDiscPctByJaldee=${providerDiscFromJaldee}  providerDiscPctBySc=${scdiscpct}  #jaldeeDiscAppliedAmt=${jaldeeDiscAppliedAmt}  
    ...   jaldeeDiscAppliedAmt=0.0  scDiscAppliedAmt=${scDiscAppliedAmt}  scDiscAppliedMonths=${scmonth}  #jaldeeDiscAppliedMonths=${jdmonth}
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${pkgId}
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${annualPrice}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['accountId']}  ${pid}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['ynwUuid']}  ${licuuid}


JD-TC-Invoice-6
    [Documentation]  Check sc validity and invoice after sc expiry

    ${resp}=  SuperAdmin Login  ${SUSERNAME}   ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp_config}=  Get SC Configuration
    Log  ${resp_config.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp_accnt_config}=  Get SCAccount Configuration
    Log  ${resp_accnt_config.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${providerDiscDuration}   ${resp_config.json()['defaultProJaldeeDiscDuration']}
    Set Test Variable  ${providerDiscFromJaldee}  ${resp_config.json()['defaultProDiscFromJaldee']}
    Set Test Variable  ${bonusPeriod}  ${resp_accnt_config.json()['scBonusPeriodDetails'][0]['value']}
    Set Test Variable  ${scType}  ${resp_accnt_config.json()['scTypeDetails'][0]['value']}
    Set Test Variable  ${commissionPct}  ${resp_config.json()['defaultComModelPct']}
    Set Test Variable  ${commissionDuration}  ${resp_config.json()['comModelMaxTillMonth']}
    Set Test Variable  ${id}   ${resp_config.json()['bonusRates'][0]['id']}
    Set Test Variable  ${targetCount}   ${resp_config.json()['bonusRates'][0]['targetCount']}
    Set Test Variable  ${rate}   ${resp_config.json()['bonusRates'][0]['rate']}
    ${radiusCoverage}  Random Int  min=0   max=10
    ${scId}=  db.Generate_ScId
    ${scName}  FakerLibrary.name
    ${contactFirstName}   FakerLibrary.first_name
    ${contactLastName}   FakerLibrary.last_name
    ${address}   db.get_address
    ${city}  db.get_place
    ${metro}   db.get_place
    ${state}   db.get_place
    ${privateNote}  FakerLibrary.name
    ${pincodesCoverage}  FakerLibrary.postcode
    ${primaryPhoneNo}=  Evaluate  ${PUSERNAME19}+5001 
    ${altPhoneNo1}=   Evaluate  ${PUSERNAME19}+5002
    ${altPhoneNo2}=  Evaluate  ${PUSERNAME19}+5003
    ${latitude}  get_latitude
    ${longitude}  get_longitude
    ${providerDiscFromJaldee}=  Convert To Number  ${providerDiscFromJaldee}  0 
    ${commissionPct}=  Convert To Number  ${commissionPct}  0
    clear_ScTable  ${primaryPhoneNo} 
    Set Test Variable  ${PrimaryEmail}    ${primaryPhoneNo}.${test_mail}
    Set Test Variable  ${altEmail2}   ${altPhoneNo2}.${test_mail}
    Set Test Variable  ${altEmail1}   ${altPhoneNo1}.${test_mail}
    
    ${resp}=  Create SA SalesChannel  ${scId}  ${providerDiscFromJaldee}  ${providerDiscDuration}  ${scName}   ${contactFirstName}  ${contactLastName}  ${address}   ${city}  ${metro}   ${state}   ${latitude}   ${longitude}   ${radiusCoverage}   ${pincodesCoverage}   ${scType}   ${primaryPhoneNo}   ${altPhoneNo1}   ${altPhoneNo2}   ${commissionDuration}   ${commissionPct}   ${PrimaryEmail}   ${altEmail1}   ${altEmail2}   ${bonusPeriod}   ${id}  ${targetCount}   ${rate}  ${privateNote}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${respo}=  SuperAdminKeywords.Get SalesChannel By Id  ${ScId}
    Log  ${respo.json()}
    ${len}=  Get Length  ${resp_config.json()['scDiscCodes']}
    ${len}=  Evaluate  ${len}-1
    ${index}=  Random Int  min=0   max=${len}
    Set Test Variable  ${month}  2
    Set Test Variable  ${scCode}  ${scId}-${resp_config.json()['scDiscCodes'][${index}]['code']}${month}-0-0
    Log  ${scCode}

    ${resp}=  get_iscorp_subdomains  0
    Set Test Variable  ${d1}  ${resp[0]['domain']}
    Set Test Variable  ${sd1}  ${resp[0]['subdomains']}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph}=  Evaluate  ${PUSERNAME7}+72015
    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    ${licindex}=  Evaluate  ${liclen}/2
    Set Test Variable  ${pkgId}  ${licresp.json()[${licindex}]['pkgId']}
    Set Test Variable  ${lprice1}  ${licresp.json()[${licindex}]['price']}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${ph}   ${pkgId}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${ph}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Create HowDoYouHearUs  ${ph}  ${HowDoYouHear[4]}  ${scCode}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${ph}${\n}
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${randomval1}    FakerLibrary.Numerify  %%%%%%%%
    ${randomval2}    FakerLibrary.Numerify  %%%%%%%%
    ${ph1}=  Evaluate  ${ph}+${randomval1}
    ${ph2}=  Evaluate  ${ph}+${randomval2}
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${ph}.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule    ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${ph}
    # ${resp}=  Get Invoices  NotPaid
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${licuuid}   ${resp.json()[0]['ynwUuid']}
    # ${len}=  Get Length  ${resp.json()}
    # Should Be Equal As Integers  ${len}  1
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  bill_cycle
    # Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${DAY1}  periodFrom=${DAY1}  periodTo=${DAY2}  amount=${lprice1}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=True  balance=0.0  providerDiscAmtByJaldee=0.0  providerDiscAmtBySc=0.0   providerDiscPctByJaldee=0.0  providerDiscPctBySc=0.0  jaldeeDiscAppliedAmt=0.0  scDiscAppliedAmt=0.0
    # Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${pkgId}
    # Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${lprice1}
    db.change_date_with_tz  ${tz}   ${DAY2} 

    Set Test Variable  ${scdiscpct}  ${resp_config.json()['scDiscCodes'][${index}]['value']}
    ${scdiscpct}=  Convert To Number  ${scdiscpct}  1
    ${discJD}=  Evaluate  float(${lprice1}*${providerDiscFromJaldee}/100)
    ${discJD}=  Convert To Number  ${discJD}  2
    ${scdiscappamnt}=  Evaluate  ${lprice1}-${discJD}
    ${discSC}=  Evaluate  float(${scdiscappamnt}*${scdiscpct}/100)
    ${discSC}=  Convert To Number  ${discSC}  2
    ${discprice}=   Evaluate  ${lprice1}-${discSC}-${discJD}
    ${amount}=  Evaluate  ${lprice1}-${discSC}-${discJD}+${lprice1}

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ProviderKeywords.Generate Invoice
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Invoices  NotPaid
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${licuuid2}   ${resp.json()[0]['ynwUuid']}
    ${DAY3}=  bill_cycle
    Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${DAY2}  periodFrom=${DAY2}  periodTo=${DAY3}  amount=${discprice}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=True  #balance=${lprice1}  
    ...   balance=0.0   providerDiscAmtByJaldee=${discJD}  providerDiscAmtBySc=${discSC}   providerDiscPctByJaldee=${providerDiscFromJaldee}  providerDiscPctBySc=${scdiscpct}  #jaldeeDiscAppliedAmt=${lprice1}  
    ...   jaldeeDiscAppliedAmt=0.0  scDiscAppliedAmt=${scdiscappamnt}  scDiscAppliedMonths=1  #jaldeeDiscAppliedMonths=1
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${pkgId}
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${lprice1}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['accountId']}  ${pid}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['ynwUuid']}  ${licuuid}
    db.change_date_with_tz  ${tz}   ${DAY3} 
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ProviderKeywords.Generate Invoice
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Invoices  NotPaid
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY4}=  bill_cycle
    ${amount3}=  Evaluate  ${amount}+${lprice1}-${discJD}
    Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${DAY3}  periodFrom=${DAY3}  periodTo=${DAY4}  #amount=${amount3}  
    ...  amount=${amount}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=True  #balance=${amount}
    ...  balance=${discprice}  providerDiscAmtByJaldee=${discJD}  providerDiscAmtBySc=0.0   providerDiscPctByJaldee=${providerDiscFromJaldee}  providerDiscPctBySc=0.0  #jaldeeDiscAppliedAmt=${lprice1}  
    ...  jaldeeDiscAppliedAmt=0.0   scDiscAppliedAmt=0.0  #jaldeeDiscAppliedMonths=1
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${pkgId}
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${lprice1}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['accountId']}  ${pid}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['ynwUuid']}  ${licuuid2}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['mergedStatements']['statements'][0]['accountId']}  ${pid}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['mergedStatements']['statements'][0]['ynwUuid']}  ${licuuid}


JD-TC-Invoice-7
    [Documentation]  apply subscription license discount
    ${resp}=  get_iscorp_subdomains  0
    Set Test Variable  ${d1}  ${resp[0]['domain']}
    Set Test Variable  ${sd1}  ${resp[0]['subdomains']}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph}=  Evaluate  ${PUSERNAME7}+72016
    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    ${index}=  Evaluate  ${liclen}/2
    Set Test Variable  ${pkgId}  ${licresp.json()[${index}]['pkgId']}
    Set Test Variable  ${lprice1}  ${licresp.json()[${index}]['price']}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${ph}   ${pkgId}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${ph}  0
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${ph}${\n}
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${randomval1}    FakerLibrary.Numerify  %%%%%%%%
    ${randomval2}    FakerLibrary.Numerify  %%%%%%%%
    ${ph1}=  Evaluate  ${ph}+${randomval1}
    ${ph2}=  Evaluate  ${ph}+${randomval2}
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${ph}.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule    ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  Get Invoices  NotPaid
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Test Variable  ${licuuid}   ${resp.json()[0]['ynwUuid']}


    ${licDiscName}=    FakerLibrary.name 
    Set Test Variable  ${licDiscName}
    ${depn}=    FakerLibrary.text 
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
	Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Get Account Config  
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${P_id}=  get_acc_id   ${ph}
    @{list}=  Create List  ${P_id}
    Set Suite Variable   ${licDiscStatus}      ${resp.json()['licDiscountStatusDetails'][0]['value']}  
    Set Suite Variable   ${licDiscType}      ${resp.json()['licDiscountTargetTypes'][4]['value']}
    ${validFrom}=  db.get_date_by_timezone  ${tz}  
    ${validTo}=   db.add_timezone_date  ${tz}   60
    ${resp}=  Get Licensable Packages
	Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${Lcode4}=  db.Generate Discount Coupon
    Log  ${Lcode4}
    ${desn}=  FakerLibrary.name
    ${lcdsp}=  FakerLibrary.Pyfloat  left_digits=2  right_digits=0  positive=True
    ${resp}=  Create License Discount code  ${Lcode4}  ${desn}  ${lcdsp}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ldicPge}=  FakerLibrary.Pyfloat  left_digits=2  right_digits=0  positive=True  
    ${resp}=  Create Subscription License Discount   ${licDiscName}  ${depn}  ${Lcode4}   ${validFrom}    ${validTo}   ${licDiscType}   ${None}  ${None}    ${None}  ${list}  ${None}  ${pkgId}   ${licDiscStatus}   ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${discId}  ${resp.json()}
    ${DAY2}=  bill_cycle
    db.change_date_with_tz  ${tz}   ${DAY2}
    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ProviderKeywords.Generate Invoice
    Should Be Equal As Strings    ${resp.status_code}   200
    ${DAY3}=  bill_cycle
    ${resp}=  Get Invoices  NotPaid
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${discamnt}=  Evaluate  float(${lprice1}*${lcdsp}/100)
    ${discamnt}=  Convert To Number  ${discamnt}  2
    ${discprice}=  Evaluate  ${lprice1}-${discamnt}
    ${amount}=  Evaluate  ${lprice1}+${lprice1}-${discamnt}
    ${lcdsp}=  Convert To Integer  ${lcdsp}  
    Verify Response List  ${resp}  0  accountId=${P_id}  createdDate=${DAY2}  periodFrom=${DAY2}  periodTo=${DAY3}  amount=${discprice}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  periodic=True  #balance=${lprice1}  
    ...   balance=0.0   providerDiscAmtByJaldee=0.0  providerDiscAmtBySc=0.0   providerDiscPctByJaldee=0.0  providerDiscPctBySc=0.0  jaldeeDiscAppliedAmt=0.0  scDiscAppliedAmt=0.0  discountTotal=${discamnt}
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${pkgId}
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${lprice1}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['accountId']}  ${pid}
    # Should Be Equal As Strings  ${resp.json()[0]['mergedStatements']['statements'][0]['ynwUuid']}  ${licuuid}
    Should Be Equal As Strings  ${resp.json()[0]['discount']['discount'][0]['id']}  ${discId}
    Should Be Equal As Strings  ${resp.json()[0]['discount']['discount'][0]['name']}  ${licDiscName}
    Should Be Equal As Strings  ${resp.json()[0]['discount']['discount'][0]['discountValue']}  ${lcdsp}
    # Should Be Equal As Strings  ${resp.json()[0]['discount']['discount'][0]['discountedAmt']}  ${discamnt}


*** Comment ***   
JD-TC-Invoice-4
    [Documentation]   check monthly invoice
    change_system_date  -5
    change_bill_cycle  ${eday}
    ${day2}=  bill_cycle
    ${resp}=   Encrypted Provider Login  ${ph}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Generate Invoice  ${pid}  monthly
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Invoices  NotPaid
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  3
    Verify Response List  ${resp}  2  accountId=${pid}  createdDate=${createdDate}  periodFrom=${createdDate}  periodTo=${eday}  amount=${resp.json()[2]['licensePkgDetails']['amount']}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  isPeriodic=True
    Should Be Equal As Strings  ${resp.json()[2]['licensePkgDetails']['licenseId']}  2
    Should Be Equal As Strings  ${resp.json()[2]['licensePkgDetails']['amount']}  ${lprice1}
    Verify Response List  ${resp}  1  accountId=${pid}  createdDate=${createdDate}  periodFrom=${createdDate}  periodTo=${eday}  amount=${resp.json()[1]['addonDetails'][0]['amount']}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  isPeriodic=False
    Should Be Equal As Strings  ${resp.json()[1]['addonDetails'][0]['addOnId']}  ${aId}
    Should Be Equal As Strings  ${resp.json()[1]['addonDetails'][0]['amount']}  ${aprice}
    ${amount}=  Evaluate  ${resp.json()[0]['addonDetails'][0]['amount']}+${resp.json()[0]['licensePkgDetails']['amount']}+${debit}-${resp.json()[0]['credit']} 
    Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${eday}  periodFrom=${eday}  periodTo=${day2}  amount=${amount}  licensePaymentStatus=NotPaid  debit=${debit}  credit=0.0  isPeriodic=True
    Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${aId}
    Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['amount']}  ${aprice}
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${licId}
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${lprice2}
    ${debit}=  get_debit  ${ph}
    Should Be Equal As Numbers  ${debit}  0.0
    sleep  02s
    ${resp}=  Get Alerts
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Invoice-8
    [Documentation]  add addon in the middle of bill cycle
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  biju  xavier  ${None}  ${d1}  ${sd1}  ${ph2}   2
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${ph2}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${ph2}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${ph2}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid2}=  get_acc_id  ${ph2}
    Set Suite Variable  ${pid2}
    ${resp}=  Get Invoices  NotPaid
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${createdDate1}  ${DAY1}
    ${DAY2}=  bill_cycle
    Verify Response List  ${resp}  0  accountId=${pid2}  createdDate=${createdDate1}  periodFrom=${createdDate1}  periodTo=${DAY2}  amount=${resp.json()[0]['licensePkgDetails']['amount']}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  isPeriodic=True
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  2
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${lprice1}
    ${daysR}=  get_days  ${DAY1}  ${DAY2}
    ${mid}=  Evaluate  ${daysR}/2
    change_system_date  ${mid}
    ${cdate}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Encrypted Provider Login  ${ph2}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Addons Metadata
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${aId}  ${resp.json()[1]['addons'][1]['addonId']}
    ${resp}=  Add addon  ${aId} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Invoices  NotPaid
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    ${amount}=  Evaluate  float(1000)/${daysR}*(${daysR}-${mid})
    ${amount}=  roundval  ${amount}  2
    Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['amount']}  ${amount}
    Should Be Equal As Strings  ${resp.json()[0]['addonDetails'][0]['addOnId']}  ${aId}
    Verify Response List  ${resp}  0  accountId=${pid2}  createdDate=${cdate}  periodFrom=${cdate}  periodTo=${DAY2}  amount=${amount}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  isPeriodic=False
    sleep  10s
    ${resp}=  Get Alerts
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${len}=  Evaluate  ${len}-1
    ${len}=  Set Variable If  ${len}<0  0  ${len}
    Should Be Equal As Strings  ${resp.json()[${len}]['text']}  Invoice has been generated with an amount of Rs ${amount}
    Should Be Equal As Strings  ${resp.json()[${len}]['subject']}    Invoice Generation

JD-TC-Invoice-9
    [Documentation]  verify invoice after basic user upgrades license
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  FCBARCELONA  LAMASIA  ${None}  ${d1}  ${sd1}  ${ph3}   1
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${ph3}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${ph3}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${ph3}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid}=  get_acc_id  ${ph3}
    ${resp}=  Get Invoices  NotPaid
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  0
    ${signupDay}=  db.get_date_by_timezone  ${tz}
    ${eday}=  bill_cycle
    change_system_date  10
    ${lday}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Encrypted Provider Login  ${ph3}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get upgradable license 
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${licId1}  ${resp.json()[1]['pkgId']}
    ${resp}=  Change License Package  ${licId}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Invoices  NotPaid
    Should Be Equal As Strings    ${resp.status_code}    200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    ${daysR}=  get_days  ${signupDay}  ${eday}
    ${daysU}=  get_days  ${lday}  ${eday}
    ${amount}=  Evaluate  float(${lprice2})/${daysR}*${daysU}
    ${amount}=  Convert To Number  ${amount}  0
    Verify Response List  ${resp}  0  accountId=${pid}  createdDate=${lday}  periodFrom=${lday}  periodTo=${eday}  amount=${amount}  licensePaymentStatus=NotPaid  debit=0.0  credit=0.0  isPeriodic=False
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['licenseId']}  ${licId}
    Should Be Equal As Strings  ${resp.json()[0]['licensePkgDetails']['amount']}  ${amount}
    sleep  02s
    ${resp}=  Get Alerts
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['text']}  Invoice has been generated with an amount of Rs ${amount}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Invoice Generation
 