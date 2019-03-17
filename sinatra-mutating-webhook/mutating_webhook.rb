require 'base64'
require 'json'
require 'sinatra'

get '/health' do
  'OK'
end

post '/fun-label', provides: 'application/json' do
  admission_review = JSON.parse(request.body.read)

  resp = {
    response: {
      uid: admission_review['request']['uid'],
      allowed: true
    }
  }

  # This annotation excludes pods from getting the patch
  annotations = admission_review['request']['object']['metadata']['annotations']
  if annotations && annotations['mutating-webhook.example.com/exclude']
    return resp.to_json
  end

  # Set the patch
  labels = admission_review['request']['object']['metadata']['labels']
  if labels
    patch = if labels['fun']
              # Replace the existing label
              [{ op: 'replace', path: '/metadata/labels/fun', value: 'hello' }]
            else
              # Add the label to the existing list of labels
              [{ op: 'add', path: '/metadata/labels/fun', value: 'hello' }]
            end
  else
    # Create the labels object with the new label
    patch = [{ op: 'add', path: '/metadata/labels', value: { fun: 'hello' } }]
  end
  resp[:response][:patch] = Base64.encode64(patch.to_json)
  resp[:response][:patchType] = 'JSONPatch'

  resp.to_json
end
