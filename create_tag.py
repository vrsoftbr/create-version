#!/usr/bin/python
import sys, requests,  getopt, os;

repo = os.getenv('GITHUB_REPOSITORY')
headers = {
    'Authorization' : "Bearer " + os.getenv('TOKEN'), 
    'Accept' : 'application/vnd.github.v3+json', 
    'Content-Type' : 'application/json'
}

def main(argv):
    tag = ''
    commit = ''
    try:
      opts, args = getopt.getopt(argv,"t:c:",["tag=","commit="])
    except getopt.GetoptError:
      print(help)
      sys.exit(2)
    for opt, arg in opts:
        if opt in ("-t", "--tag"):
            tag = arg
        elif opt in ("-c", "--commit"):
            commit = arg

    tag_hash = create_tag(tag, commit)
    create_tag_ref(tag, tag_hash)

def create_tag(tag, commit):
    url = "https://api.github.com/repos/" + repo + "/git/tags"
    commit_messages = ''
    with open(os.getenv('TEMP_FILE'), 'r') as file:
        commit_messages = file.read()

    payload = {
        "tag": tag,
        "message": commit_messages,
        "object": commit,
        "type": "commit"
    }
    r = requests.post(url, json=payload, headers=headers)
    print(r.json())
    return r.json()['sha']

def create_tag_ref(tag, tag_sha):
    url = "https://api.github.com/repos/" + repo + "/git/refs"
    payload = {
        "ref": "refs/tags/" + tag,
        "sha": tag_sha
    }

    requests.post(url, json=payload, headers=headers)

if __name__ == "__main__":
   main(sys.argv[1:])