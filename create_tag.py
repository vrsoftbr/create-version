#!/usr/bin/python
import sys, requests,  getopt, os;

headers = {
    'Authorization' : "Bearer " + os.getenv('TOKEN'), 
    'Accept' : 'application/vnd.github.v3+json', 
    'Content-Type' : 'application/json'
}

def main(argv):
    tag = ''
    commit = ''
    repo = ''
    try:
      opts, args = getopt.getopt(argv,"t:c:r:",["tag=","commit=", "repo="])
    except getopt.GetoptError:
      print(help)
      sys.exit(2)
    for opt, arg in opts:
        if opt in ("-t", "--tag"):
            tag = arg
        elif opt in ("-c", "--commit"):
            commit = arg
        elif opt in ("-r", "--repo"):
            repo = arg

    tag_hash = create_tag(tag, commit, repo)
    create_tag_ref(tag, tag_hash, repo)

def create_tag(tag, commit, repo):
    url = "https://api.github.com/repos/" + repo + "/git/tags"
    commit_messages = ''
    with open(os.getenv('TEMP_FILE'), 'r') as file:
        commit_messages = file.read().replace("\"", "\\\"")

    payload = {
        "tag": tag,
        "message": commit_messages,
        "object": commit,
        "type": "commit"
    }
    print(payload)
    r = requests.post(url, json=payload, headers=headers)
    print(r.json())
    return r.json()['sha']

def create_tag_ref(tag, tag_sha, repo):
    url = "https://api.github.com/repos/" + repo + "/git/refs"
    payload = {
        "ref": "refs/tags/" + tag,
        "sha": tag_sha
    }

    requests.post(url, json=payload, headers=headers)

if __name__ == "__main__":
   main(sys.argv[1:])
