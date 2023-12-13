interface/talentframe/specializationclassthumbnails
interface/store/expansiontrialpopupbfa
interface/garrison/garrisontoast

<Button name="EncounterInstanceButtonTemplate" hidden="true" virtual="true">
		<Size x="174" y="96"/>
		<Layers>
			<Layer level="BACKGROUND">
				<Texture name="$parentbgImage" parentKey="bgImage">
					<Anchors>
						<Anchor point="TOPLEFT" x="0" y="0"/>
						<Anchor point="BOTTOMRIGHT" x="0" y="0"/>
					</Anchors>
					<TexCoords left="0" right="0.68359375" top="0" bottom="0.7421875"/>
				</Texture>
			</Layer>
			<Layer level="OVERLAY">
				<Texture name="$parentHeroicIcon" file="Interface\EncounterJournal\UI-EJ-HeroicTextIcon" parentKey="heroicIcon" hidden="true">
					<Anchors>
						<Anchor point="BOTTOMRIGHT" x="-7" y="7"/>
					</Anchors>
				</Texture>
				<FontString name="$parentName" inherits="QuestTitleFontBlackShadow" parentKey="name">
					<Size x="150" y="0"/>
					<Anchors>
						<Anchor point="TOP" x="0" y="-15"/>
					</Anchors>
				</FontString>
				<FontString name="$parentRange" inherits="GameFontNormal" justifyH="LEFT" parentKey="range" text="82-83" hidden="true">
					<Size x="100" y="12"/>
					<Anchors>
						<Anchor point="BOTTOMLEFT" x="7" y="7"/>
					</Anchors>
				</FontString>
			</Layer>
		</Layers>
		<NormalTexture inherits="UI-EJ-DungeonButton-Up">
		</NormalTexture>
		<PushedTexture inherits="UI-EJ-DungeonButton-Down">
		</PushedTexture>
		<HighlightTexture inherits="UI-EJ-DungeonButton-Highlight">
		<Frames>
			<Button parentKey="ModifiedInstanceIcon" hidden="true" mixin="ModifiedInstanceIconMixin">
				<Anchors>
					<Anchor point="TOPRIGHT" x="8" y="6"/>
				</Anchors>
				<Layers>
					<Layer level="BORDER">
						<Texture parentKey="Icon"/>
					</Layer>
				</Layers>
				<Scripts>
					<OnEnter method="OnEnter"/>
					<OnLeave method="OnLeave"/>
				</Scripts>
			</Button>
		</Frames>
	</Button>


Template: PortraitFrameTemplate

			<Frame name="$parentInstanceSelect" parentKey="instanceSelect" useParentLevel="true">
				<Anchors>
					<Anchor point="TOPLEFT" relativeTo="$parentInset" x="0" y="-2" />
					<Anchor point="BOTTOMRIGHT" relativeTo="$parentInset" x="-3" y="0"/>
				</Anchors>
				<Layers>
					<Layer level="BACKGROUND">
						<Texture name="$parentBG" file="Interface\EncounterJournal\UI-EJ-Cataclysm" parentKey="bg">
							<Anchors>
								<Anchor point="TOPLEFT" x="3" y="-1"/>
							</Anchors>
						</Texture>
					</Layer>
					<Layer level="OVERLAY">
						<FontString parentKey="Title" inherits="GameFontNormalLarge2" justifyH="LEFT" text="MONTHLY_ACTIVITIES_TAB">
							<Anchors>
								<Anchor point="TOPLEFT" x="20" y="-15"/>
							</Anchors>
						</FontString>
					</Layer>
				</Layers>
				<Frames>
					<Frame name="$parentTierDropDown" parentKey="tierDropDown" inherits="UIDropDownMenuTemplate">
						<Size x="156" y="32"/>
						<Anchors>
							<Anchor point="TOPRIGHT" x="0" y="-10"/>
						</Anchors>
						<Scripts>
							<OnShow>
								UIDropDownMenu_SetWidth(self, 156);
								UIDropDownMenu_JustifyText(self, "LEFT");
								UIDropDownMenu_Initialize(self, EJTierDropDown_Initialize);
							</OnShow>
						</Scripts>
					</Frame>

					<Frame parentKey="ScrollBox" inherits="WowScrollBoxList">
						<Size x="748" y="367"/>
						<Anchors>
							<Anchor point="TOPLEFT" x="14" y="-50"/>
						</Anchors>
					</Frame>
					<EventFrame parentKey="ScrollBar" inherits="MinimalScrollBar">
						<Anchors>
							<Anchor point="TOPLEFT" relativeKey="$parent.ScrollBox" relativePoint="TOPRIGHT" x="12" y="-6"/>
							<Anchor point="BOTTOMLEFT" relativeKey="$parent.ScrollBox" relativePoint="BOTTOMRIGHT" x="12" y="-4"/>
						</Anchors>
					</EventFrame>
				</Frames>
			</Frame>


