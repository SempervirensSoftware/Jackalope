class TreeController < ApplicationController
  
  def show     
    @github = Github.new(:oauth_token => params[:token])  
    @github.user = params[:repoOwner]
    @repo = params[:repoName]

    treeSHA = params[:treeSha]    
    @response = @github.git_data.tree @github.user, @repo, treeSHA    
    
    respond_to do |format|
        format.json { render :json => @response }
    end    
  end  
  
  def create
    token = params[:token]
    @github = Github.new(:oauth_token => token)
    repoOwner = params[:repoOwner]
    authorEmail = params[:authorEmail]
    authorName = params[:authorName]
  
    @repo = params[:repoName]
    repoRootSHA = params[:repoRootSHA]
    
    currentCommit = params[:commitSHA]
    currentRef = "refs/heads/#{params[:branchName]}"
    
    blobName = params[:blobName]
    blobFullPath = params[:blobFullPath]
    blobSha = params[:blobSHA]
    blobContent = params[:blobContent]
    commitMessage = "#{params[:commitMessage]} - Commited with Jackalope (http://jackalope.me)"
    
    #Create a new tree with the modified contents      
      uri = URI.parse("https://api.github.com/repos/#{repoOwner}/#{@repo}/git/trees?access_token=#{token}")
    
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
      treeRequest = Net::HTTP::Post.new(uri.request_uri)
      postTree = {"path" => blobFullPath, "mode" => "100644", "type" => "blob", "content" => blobContent}
      treeRequest.body = {"base_tree" => repoRootSHA, "tree" => [postTree]}.to_json
    
      treeResponse = http.request(treeRequest) 
      newTree = JSON.parse(treeResponse.body)
          
    # Create a new commit        
      uri = URI.parse("https://api.github.com/repos/#{repoOwner}/#{@repo}/git/commits?access_token=#{token}")
    
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
      commitRequest = Net::HTTP::Post.new(uri.request_uri)
      commitRequest.body = {"message" => commitMessage,"tree" => newTree["sha"],"parents" => [currentCommit], "author" => {"email" => authorEmail, "name" => authorName}}.to_json
    
      commitResponse = http.request(commitRequest)
      newCommit = JSON.parse(commitResponse.body)
      
    # Update the branch ref to the new commit
      uri = URI.parse("https://api.github.com/repos/#{repoOwner}/#{@repo}/git/#{currentRef}?access_token=#{token}")
    
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
      refRequest = Net::HTTP::Post.new(uri.request_uri)
      refRequest.body = {"sha" => newCommit["sha"] ,"force" => true}.to_json
      
      refResponse = http.request(refRequest)
      newRef = JSON.parse(refResponse.body)
  
      respond_to do |format|
        format.json { render :json => newCommit }
      end
  end
end