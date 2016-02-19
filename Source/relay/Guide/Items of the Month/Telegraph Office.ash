import "relay/Guide/Support/Location Choice.ash";

RegisterTaskGenerationFunction("IOTMTelegraphOfficeGenerateTasks");
void IOTMTelegraphOfficeGenerateTasks(ChecklistEntry [int] task_entries, ChecklistEntry [int] optional_task_entries, ChecklistEntry [int] future_task_entries)
{
    if (in_bad_moon() || !get_property_boolean("telegraphOfficeAvailable"))
        return;
    
    
    if (lookupItem("your cowboy boots").available_amount() == 0)
    {
        optional_task_entries.listAppend(ChecklistEntryMake("__item your cowboy boots", "place.php?whichplace=town_right", ChecklistSubentryMake("Acquire your cowboy boots", "", "Visit the LT&T office."), 0));
        
    }
    
    
    if (!mafiaIsPastRevision(16674))
        return;
    
    QuestState ltt_quest = QuestState("questLTTQuestByWire");
    
    if (!ltt_quest.in_progress)
        return;
    
    int difficulty = get_property_int("lttQuestDifficulty");
    int stage_count = get_property_int("lttQuestStageCount");
    string quest_name = get_property("lttQuestName");
    if (quest_name == "")
        return;
    
    //step1 - the investigation begins
    //step2 - The Investigation Continues
    //step3 - The Investigation Continues
    //step4 - boss fight
    
    int turns_completed = stage_count;
    if (ltt_quest.mafia_internal_step > 2)
        turns_completed += 10;
    if (ltt_quest.mafia_internal_step > 3)
        turns_completed += 10;
    if (ltt_quest.mafia_internal_step > 4)
        turns_completed += 10;
        //quest_name is blank when not on the quest
    int turns_remaining = clampi(29 - turns_completed, 0, 29);
    //"Missing: Many Children" - clara
    //"Wagon Train Escort Wanted" - Granny Hackleton
    //"Madness at the Mine" - unusual construct
    
    monster [string] boss_for_quest;
    
    boss_for_quest["Missing: Fancy Man"] = lookupMonster("Jeff the Fancy Skeleton");
    boss_for_quest["Help! Desperados!"] = lookupMonster("Pecos Dave");
    boss_for_quest["Missing: Pioneer Daughter"] = lookupMonster("Daisy the Unclean");
    
    boss_for_quest["Big Gambling Tournament Announced"] = lookupMonster("Snake-Eyes Glenn");
    boss_for_quest["Haunted Boneyard"] = lookupMonster("Pharaoh Amoon-Ra Cowtep");
    boss_for_quest["Sheriff Wanted"] = lookupMonster("Former Sheriff Dan Driscoll");
    
    boss_for_quest["Missing: Many Children"] = lookupMonster("clara");
    boss_for_quest["Wagon Train Escort Wanted"] = lookupMonster("Granny Hackleton");
    boss_for_quest["Madness at the Mine"] = lookupMonster("unusual construct");
    
    
    
    string [int] description;
    string [int] modifiers;
    if (turns_remaining > 0)
        description.listAppend(pluraliseWordy(turns_remaining, "more turn", "more turns").capitaliseFirstLetter() + " until the boss.");
    if (turns_remaining == 0 || ltt_quest.mafia_internal_step == 5)
    {
        monster boss = boss_for_quest[quest_name];
        if (boss == $monster[none])
            description.listAppend("Defeat the boss.");
        else
            description.listAppend("Defeat " + boss + ".");
        boolean frigidalmatian_eligible = false;
        if (boss == lookupMonster("clara"))
        {
            modifiers.listAppend("+elemental resistance");
            description.listAppend("Use high-damage spells, like shrap + snow mobile/green lantern.");
            frigidalmatian_eligible = true;
        }
        else if (boss == lookupMonster("Granny Hackleton"))
        {
            description.listAppend("Use different high-damage combat items, or frigidalmatian and attack.");
            //FIXME suggest a list of combat items to use
            frigidalmatian_eligible = true;
        }
        else if (boss == lookupMonster("unusual construct"))
        {
            description.listAppend("Each round, you have to respond with the correct shiny disc to survive. Mafia will select the correct one.|Maybe funksling with new-age hurting crystals.");
            frigidalmatian_eligible = true;
        }
        else if (boss == lookupMonster("Jeff the Fancy Skeleton"))
        {
            description.listAppend("Attack with a blunt weapon.");
            description.listAppend("Combat items won't work, skills are mostly blocked.");
        }
        else if (boss == lookupMonster("Pecos Dave"))
        {
            //FIXME
        }
        else if (boss == lookupMonster("Daisy the Unclean"))
        {
            //FIXME
        }
        else if (boss == lookupMonster("Snake-Eyes Glenn"))
        {
            description.listAppend("Immune to all but a single element type each round.|Previous round's second roll indicates which.");
        }
        else if (boss == lookupMonster("Pharaoh Amoon-Ra Cowtep"))
        {
            description.listAppend("Avoid attacking with spell damage.");
        }
        else if (boss == lookupMonster("Former Sheriff Dan Driscoll"))
        {
            description.listAppend("Acquire passive damage (glowing syringes?), attack repeatedly.");
            frigidalmatian_eligible = true;
        }
        
        if (frigidalmatian_eligible)
        {
            string [int] tasks;
            boolean frigidalmatian_obtainable = false;
            if ($effect[frigidalmatian].have_effect() > 0)
                frigidalmatian_obtainable = true;
            if ($effect[frigidalmatian].have_effect() == 0 && $skill[frigidalmatian].have_skill())
            {
                frigidalmatian_obtainable = true;
                tasks.listAppend("cast frigidalmatian");
            }
            if (frigidalmatian_obtainable && $items[rain-doh green lantern,snow mobile].equipped_amount() == 0)
            {
                if ($item[rain-doh green lantern].available_amount() > 0)
                {
                    tasks.listAppend("equip rain-doh green lantern");
                }
                else if ($item[snow mobile].is_unrestricted())
                {
                    if ($item[snow mobile].available_amount() > 0)
                    {
                        tasks.listAppend("equip snow mobile");
                    }
                    else
                        tasks.listAppend("acquire and equip snow mobile");
                }
            }
            if (tasks.count() > 0)
                description.listAppend(tasks.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".");
        }
    }
    
    if (false)
    {
        foreach s in $strings[lttQuestDifficulty,lttQuestStageCount,lttQuestName,questLTTQuestByWire]
            description.listAppend(s + " = " + get_property(s));
    }
    
    optional_task_entries.listAppend(ChecklistEntryMake("__item sea cowboy hat", "inventory.php?which=3", ChecklistSubentryMake(quest_name, modifiers, description), lookupLocations("Investigating a Plaintive Telegram")));
}

RegisterResourceGenerationFunction("IOTMTelegraphOfficeGenerateResource");
void IOTMTelegraphOfficeGenerateResource(ChecklistEntry [int] resource_entries)
{
    if (__misc_state["in run"] && lookupItem("Clara's bell").available_amount() > 0 && !get_property_boolean("_claraBellUsed"))
    {
        string [int] description;
        description.listAppend("Ring for a non-combat next turn, once/day.");
        
        LocationChoice [int] options;
        
        //√spooky forest - unlocking the hidden temple
        //6 - advance one of the quest areas
        //7 - defiled cranny
        //8 - umm... maybe the extreme slow? unimportant?
        //9 - twin peak
        //10 - top/bottom of the castle, best place in the game(?)
        //11 - copperhead, protestors, probably not the hidden city?, hidden temple but marginal, palindome but marginal, pyramid in situations where you can't run lots of +item, poop deck, haunted billiards room, haunted bathroom
        //12 - starting the war(??)
        
        //2 - mosquito - not terribly important
        //3 - tavern - forces a skippable NC, not important
        
        if (!get_property_ascension("lastTempleUnlock"))
        {
            //options.listAppend("")
            options.listAppend(LocationChoiceMake($location[the spooky forest], "unlocking the hidden temple"));
        }
        
        if (my_path_id() == PATH_COMMUNITY_SERVICE)
        {
            foreach key in options
                remove options[key];
        }
        
        if (options.count() > 0)
        {
            description.listAppend("Suggested areas:|*" + LocationChoiceGenerateDescription(options).listJoinComponents("|*"));
        }
        
        
        resource_entries.listAppend(ChecklistEntryMake("__item clara's bell", "inventory.php?which=3", ChecklistSubentryMake("Clara's Bell", "", description), 5));
    }
}