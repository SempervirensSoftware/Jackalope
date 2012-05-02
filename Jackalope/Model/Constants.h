//
//  Constants.h
//  Jackalope
//
//  Created by Peter Terrill on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

typedef enum {
    ERROR_GENERIC                   = 1, 
    ERROR_USER_NOT_FOUND            = 100, 
    ERROR_PARAM_NOT_FOUND           = 200,
    ERROR_PARAM_TOKEN_NOT_FOUND     = 201
}ERROR_CODES;

typedef enum {
    APP_TAB_FEED,
    APP_TAB_REPOS, 
    APP_TAB_COMMITS
}APP_TAB;
