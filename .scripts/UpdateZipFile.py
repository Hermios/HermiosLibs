import os
import json
from github import Github
from glob import glob
import requests, io
from zipfile import ZipFile
import shutil

################################# Load data ###############################
# Get env data
pull_request=json.loads(os.environ["PULL_REQUEST"])
github=Github(os.environ["OAUTH_TOKEN"])
# Get Repository
repo=github.get_user().get_repo(pull_request["base"]["repo"]["name"])

previous_zip_file_name=f"{repo.name}-{os.environ['RELEASE_VERSION']}"
zip_file_name=f"{repo.name}_{os.environ['RELEASE_VERSION']}"

################################# Extract zip file and remove non factorio content ###############################
with requests.get(f"https://github.com/{repo.full_name}/archive/refs/tags/{os.environ['RELEASE_VERSION']}.zip", headers={"Authorization": f"token {os.environ['OAUTH_TOKEN']}"}) as r:
    with open('release.zip', 'wb') as fh:
        fh.write(r.content)
with ZipFile('release.zip') as z:
    z.extractall()
os.remove('release.zip')
os.rename(previous_zip_file_name,zip_file_name)

# remove all non factorio directories
[shutil.rmtree(d) for d in glob(f"./{zip_file_name}/.*")]

################################# Set info.json ###############################
try:
    mod_dependancies=json.loads(repo.get_variable("MOD_DEPENDANCIES").value)
except:
    mod_dependancies=[]
mod_dependancies.insert(0,f"base>={os.environ['FACTORIO_RELEASE']}")

info_json={
  "name": repo.name,
  "version": os.environ['RELEASE_VERSION'],
  "title": repo.get_variable("MOD_TITLE").value,
  "author": repo.get_variable("MOD_AUTHOR").value,
  "homepage": repo.url,
  "dependencies": mod_dependancies,
  "description": repo.get_variable("MOD_DESCRIPTION").value,
  "factorio_version": os.environ['FACTORIO_RELEASE'][:os.environ['FACTORIO_RELEASE'].rfind('.')]
}

# create info.json file
with open(f'{zip_file_name}/info.json','w') as info:
    info.write(json.dumps(info_json,indent=2))

################################# Set changelog ###############################
changelog=""
for release in repo.get_releases():
    changelog+=f"""---------------------------------------------------------------------------------------------------
Version: {release.tag_name}
Date: {release.created_at.strftime('%d-%m-%Y')}
{release.body}"""

# create changelog file
with open(f'{zip_file_name}/changelog.txt','w') as info:
    info.write(changelog)

################################# create new zip file ###############################
with ZipFile(f"{zip_file_name}.zip", "w") as zf:
    for dirname, subdirs, files in os.walk(zip_file_name):
        zf.write(dirname)
        for filename in files:
            zf.write(os.path.join(dirname, filename))

################################# send mod ###############################
data = {mod: f"{zip_file_name}.zip"}
request_headers = {"Authorization": f"Bearer {os.environ['FACTORIO_MOD_API_KEY']}"}

response = requests.post("https://mods.factorio.com/api/v2/mods/init_publish", data=data, headers=request_headers)

if not response.ok:
    print(f"init_upload failed: {response.text}")
    exit(1)

upload_url = response.json()["upload_url"]
data={
    description: repo.get_contents("README.md").decoded_content.decode(),
    category:os.getenv("MOD_CATEGORY"),
    license:os.getenv("MOD_LICENCE"),
    source_url:repo.url
}
with open(f"{zip_file_name}.zip", "rb") as f:
    request_body = {"file": f}
    requests.post(upload_url, files=request_body, data={"description": "# published via API"})


if not response.ok:
    print(f"upload failed: {response.text}")
    exit(1)