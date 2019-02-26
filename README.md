# Icebreaker

Icebreaker was an old script we used for the second iteration of our repo. 

It's a convuluted, repo-specific system that we wouldn't recommend using anywhere. We're just posting it here for archival purposes.

You can find the documentation we used internally below.

# Icebreaker Guide

As an artist, you want to get up and running with the repo as soon as possible so you can get busy with your art.

Once you get the repo cloned and setup according to the contributing guide, there is one extra thing you'll have to do to make sure everything is set up correctly:

```bash
icebreaker branch master all
```

This will ensure that you're getting the latest changes, along with pre-built binaries. Next, whenever you want to update, do the following:

```bash
icebreaker sync all
```

This will (in order) update the base code and core game files, update all art assets, and update your pre-built binaries.

So, next up is contributing. If you want to add an asset to a node, you'll have to make a new branch for it first so a team member can review it and then merge it into the main branch once approved.

```bash
icebreaker branch <branch-name> <nodes...>
```

So let's say you wanted to add some cabinet models to Ravenholm. Your branch name is something short but descriptive. Artists also usually put their name in branch names, so it will look something like this: `mastercoms-fancy-cabinet`. Then, since you're adding a model to Ravenholm, you would be using the `Ravenholm/models` node. So with this example, the command would look like this:

```bash
icebreaker branch mastercoms-fancy-cabinet Ravenholm/models
```

You can branch as many nodes as you with this command. So if you wanted to also add sounds for the cabinet because you're an extra talented modeler and sound designer:

```bash
icebreaker branch mastercoms-fancy-cabinet Ravenholm/models Ravenholm/sounds
```

You can even specify whole modules, like `Ravenholm` or even `all`! (though these will rarely be useful for any artists).

Next, you'll want to import these assets into Unreal Engine to the relevant `Content\` folder, according to your departments' chosen folder structure. For our example, you would be adding the cabinet to `Content\Ravenholm\models` according to the 3D team's asset structure guidelines. Make sure you only add `.uasset` files with no source files preset. Once that's done, it's time to publish your changes!

```bash
icebreaker publish <nodes...>
```

This will open up a text editor where you'll write a summary of your changes. You can optionally write up a longer description by making a new paragraph separated by a line from the short summary. So, for our cabinet example, here's how that would look like:

```bash
icebreaker publish Ravenholm/models
```

Then in the text editor (hopefully you have Notepad++ and not Vim), write your commit message at the top, above the summary of files changes. Then save and close once you're done to continue on to pushing it to GitLab. For our example:

```
Added initial cabinet model

This cabinet model is a very fancy one to only be used in very special places because it's not fair to the cabinet if it's placed up in front of just any old plaster wall.
```

In the GitLab push message, it will again give you a summary of the files you changed, as well as a link to open a merge request. A merge request is something on GitLab that allows other people to put your changes to the main branch. So click on that link and open the merge request on the page that opens!

Make sure you share your merge request in the `#merge-logs` to help people track what merge requests have been sent!

After you've finished work on something, you'll want to switch back to master so you have the latest changes. So for all the nodes, just branch back:

```bash
icebreaker branch master Ravenholm/models
```

And then update according to the instructions already discussed above.
