*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        FavoriteProvider
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py

*** Test Cases ***
JD-TC-AddFavouriteProvider-1
      [Documentation]    Add a provider as favourite
      ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${id}=  get_acc_id  ${PUSERNAME1}
      Set Suite Variable  ${id1}  ${id}
      ${resp}=  Add Favourite Provider  ${id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  List Favourite Provider
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  id=${id}
      ${resp}=  Consumer Logout
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200      
 
JD-TC-AddFavouriteProvider-2
      [Documentation]  a provider is being added as favourite by multiple consumers
      ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${id}=  get_acc_id  ${PUSERNAME2}
      ${resp}=  Add Favourite Provider  ${id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  List Favourite Provider
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  id=${id}  
      ${resp}=  Consumer Logout
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add Favourite Provider  ${id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  List Favourite Provider
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  id=${id}      

# JD-TC-AddFavouriteProvider-3
#       [Documentation]   a provider switched to consumer and adds another provider his favourite(Provider is favourite himself)
#       ${resp}=  Consumer Login  ${PUSERNAME2}  ${PASSWORD}
#       Log   ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       ${id1}=  get_acc_id  ${PUSERNAME2}
#       ${id}=  get_acc_id  ${PUSERNAME0}
#       ${resp}=  Add Favourite Provider  ${id}
#       Log   ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       ${resp}=  List Favourite Provider
#       Log   ${resp.json()}
#       Verify Response List  ${resp}  0  id=${id1}
#       Verify Response List  ${resp}  1  id=${id}

# JD-TC-AddFavouriteProvider-UH1
#       [Documentation]  a provider switched to consumer and adds himself as his favourite(default provider himself favourite)
#       ${resp}=  Consumer Login  ${PUSERNAME2}  ${PASSWORD}
#       Log   ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       ${id}=  get_acc_id  ${PUSERNAME0}
#       ${id1}=  get_acc_id  ${PUSERNAME2}
#       ${resp}=  Add Favourite Provider  ${id1}
#       Log   ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}  422
#       Should Be Equal As Strings  "${resp.json()}"  "${PROVIDER_ALREADY_FAVOURITE}"

JD-TC-AddFavouriteProvider-UH2
      [Documentation]  Add a favourite provider without login
      ${resp}=  Add Favourite Provider  ${id1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"
      

JD-TC-AddFavouriteProvider-UH3
     [Documentation]  adding alreay added provider again to the favourite list
     ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Add Favourite Provider  ${id1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"      "${PROVIDER_ALREADY_FAVOURITE}"
     

JD-TC-AddFavouriteProvider-UH4
      [Documentation]  call the url with a non-existing accout id
      ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${id}=  get_acc_id  ${Invalid_email}
      ${resp}=  Add Favourite Provider  ${id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422 
      Should Be Equal As Strings  "${resp.json()}"     "${PROVIDER_NOT_EXIST}"

JD-TC-AddFavouriteProvider-UH5
      [Documentation]  Create inactive account
      ${INACTIVE_PUSER}=  Evaluate  ${PUSERNAME}+685323
      Set Suite Variable   ${INACTIVE_PUSER}
      Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${INACTIVE_PUSER}${\n}
      ${licresp}=   Get Licensable Packages
      Should Be Equal As Strings   ${licresp.status_code}   200
      ${liclen}=  Get Length  ${licresp.json()}
      FOR  ${pos}  IN RANGE  ${liclen}
            Set Test Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
            Set Test Variable  ${pkg_name}  ${licresp.json()[${pos}]['displayName']}
      END
      ${domresp}=  Get BusinessDomainsConf
      Should Be Equal As Strings  ${domresp.status_code}  200
      ${dlen}=  Get Length  ${domresp.json()}
      FOR  ${pos}  IN RANGE  ${dlen}
            ${sublen}=  Get Length  ${domresp.json()[${pos}]['subDomains']}
            Set Test Variable  ${dpos}   ${pos}
            Set Test Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
      END

      FOR  ${pos}  IN RANGE  ${sublen}
            Set Test Variable  ${sd1}  ${domresp.json()[${dpos}]['subDomains'][${pos}]['subDomain']}
      END

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${INACTIVE_PUSER}    ${pkgId}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${INACTIVE_PUSER}${\n}
      ${resp}=  Account Activation  ${INACTIVE_PUSER}  0
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${INACTIVE_PUSER}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${INACTIVE_PUSER}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200
      # comment  Consumer adding a inactive account as favourite
      ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${id}=  get_acc_id  ${INACTIVE_PUSER}
      ${resp}=  Add Favourite Provider  ${id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # Should Be Equal As Strings  ${resp.status_code}  422
      # Should Be Equal As Strings  "${resp.json()}"     "${ACCOUNT_NOT_ACTIVATED}"
   

   
