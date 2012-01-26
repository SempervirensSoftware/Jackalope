//
//  Code.m
//  Touch Code
//
//  Created by Peter Terrill on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Code.h"
#import "NSAttributedString+Attributes.h"
#import "LineOfCode.h"

@implementation Code

@synthesize plainText = _plainText;
@synthesize fileName = _fileName;

-(id) init
{
    return [self initWithPath:nil AndContents:nil];
}

// Prototype Only!
-(void) demoInit
{
    _plainText =   @"class RepoController < ApplicationController\n"        
    "\n"
    "\tdef index\n"
    "\t\tgitHubInit()\n"
    "\n"
    "\t\t@response = @github.repos.list_repos\n"
    "\n"
    "\t\trespond_to do |format|\n"
    "\t\t\tformat.json { render :json => @response }\n"
    "\t\tend\n"
    "\tend\n"
    
    @"\n\tdef show \n"
    @"\t\tgitHubInit() \n"
    @"\t\t@repo = params[:id] \n"
    
    @"\n\t\tlastCommit_SHA = nil\n"
    @"\t\tbranch_Name = \"master\"\n"
    @"\t\tbranch_Rec = @github.repos.branches @github.user, @repo\n"
    
    @"\n\t\tif (branch_Rec.count == 0)\n"
    @"\t\t\treturn nil\n"
    @"\t\telsif (branch_Rec.count == 1)\n"
    @"\t\t\tcommitRec = @github.git_data.commit @github.user, @repo, branch_Rec[0].commit.sha\n"
    @"\n\t\t\t@response = @github.git_data.tree @github.user, @repo, commitRec.tree.sha\n"
    @"\t\t\t@response[\"commit\"] = branch_Rec[0].commit.sha\n"
    @"\t\t\t@response[\"path\"] = @repo\n"
    @"\t\t\t@response[\"type\"] = \"tree\"\n"
    @"\t\telse\n"
    @"\t\t\t@response = branch_Rec\n"
    @"\t\tend\n"
    
    @"\n\t\trespond_to do |format|\n"
    @"\t\t\tformat.json { render :json => @response }\n"
    @"\t\tend\n"
    @"\tend\n"    
    
    @"\n\tdef gitHubInit\n"
    @"\t\t# hardcoding the login for now\n"
    @"\t\t@github.user = 'SempervirensSoftware'\n"
    @"\tend\n"
    @"\nend";
}

-(id) initWithPath:(NSString*)path AndContents:(NSString*)contents;
{
    self = [super init];
    
    if (self)
    {
        _plainText = contents;
        _fileName = path;
        
        // Prototype Only!
        [self demoInit];
    }
    
    return self;
}



    
@end
