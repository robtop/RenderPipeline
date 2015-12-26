
from panda3d.core import Camera, NodePath, SamplerState, Texture

from ..RenderStage import RenderStage
from ..Globals import Globals

class ShadowStage(RenderStage):

    """ This is the stage which renders all shadows """
    required_inputs = []

    def __init__(self, pipeline):
        RenderStage.__init__(self, "ShadowStage", pipeline)
        self._size = 4096

    def set_size(self, size):
        self._size = size

    def get_produced_pipes(self):
        return {
            "ShadowAtlas": self._target["depth"],
            "ShadowAtlasPCF": (self._target['depth'], self.make_pcf_state()),
        }

    def make_pcf_state(self):
        state = SamplerState()
        state.set_minfilter(Texture.FT_shadow)
        state.set_magfilter(Texture.FT_shadow)
        return state

    def create(self):
        self._target = self._create_target("ShadowAtlas")
        self._target.set_source(source_cam=NodePath(Camera("dummy_shadow_cam")), source_win=Globals.base.win)
        self._target.set_size(self._size, self._size)
        self._target.set_create_overlay_quad(False)
        self._target.add_depth_texture(bits=32)
        self._target.prepare_scene_render()

        # Disable all clears
        self._target.get_internal_region().disable_clears()
        self._target.get_internal_buffer().disable_clears()

        self._target.set_clear_depth(False)



    def set_shader_input(self, *args):
        Globals.render.set_shader_input(*args)

    def resize(self):
        RenderStage.resize(self)
        self.debug("Resizing pass")

    def cleanup(self):
        RenderStage.cleanup(self)
        self.debug("Cleanup pass")